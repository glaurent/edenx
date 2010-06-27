//
//  CompositionController.m
//  edenx
//
//  Created by Guillaume Laurent on 3/1/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "CompositionController.h"
#import "CoreDataStuff.h"
#import "TimeSignatureController.h"
#import "MyDocument.h"
#import "CoreDataUtils.h"
#import "CoreDataStuff.h"

@implementation CompositionController

- (id)initWithContent:(id)content
{
    NSLog(@"CompositionController:initWithContent");
    
    [super initWithContent:content];
    
    dummyTimeSig = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSignature"
                                                 inManagedObjectContext:[self managedObjectContext]];
    barPositionsNeedCalculating = YES;

    document = [[NSDocumentController sharedDocumentController] currentDocument];
    
    return self;
}

- (void)setContent:(id)content
{
    NSLog(@"CompositionController:setContent %@", content);
    [super setContent:content];
    [[[NSDocumentController sharedDocumentController] currentDocument] setupZoomSlider]; // TODO - gotta be a better way to do this
}

- (void)prepareContent
{
    
    NSLog(@"CompositionController:prepareContent");
    
    [super prepareContent];
    
    // check if there's an entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *fetchError = nil;
    NSArray *fetchResults;
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Composition"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setEntity:entity];
    fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
    
    if ((fetchResults != nil) && ([fetchResults count] == 1) && (fetchError == nil))
    {
        NSLog(@"CompositionController:prepareContent - super found an entity - nothing to do");
    } else {
        NSLog(@"CompositionController:prepareContent - create new Composition instance");
        
        NSManagedObject* newComposition = [NSEntityDescription insertNewObjectForEntityForName:@"Composition"
                                                                        inManagedObjectContext:moc];

        // also create default tempo and time signature objects
        //
        NSManagedObject<Tempo>* newTempo = [NSEntityDescription insertNewObjectForEntityForName:@"Tempo"
                                                                         inManagedObjectContext:moc];
        newTempo.composition = newComposition;

        NSManagedObject<TimeSignature>* newTimeSignature = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSignature"
                                                                                         inManagedObjectContext:moc];

        newTimeSignature.composition = newComposition;
        
        // To avoid undo registration for this insertion, removeAllActions on the undoManager.
        // First call processPendingChanges on the managed object context to force the undo registration
        // for this insertion, then call removeAllActions.
        [moc processPendingChanges];
        [[moc undoManager] removeAllActions];        
    }
    
}

- (void)calculateBarPositions
{
    if (!barPositionsNeedCalculating)
        return;

    id<Composition> composition = [self content];
    
    
    NSArray* sortedTimeSignatures = [[document timeSignaturesController] arrangedObjects];
    NSEnumerator *timeSigsEnumerator = [sortedTimeSignatures objectEnumerator];
    
    uint lastBarNo = 0;
    timeT lastSigTime = 0;
    timeT barDuration = [TimeSignatureController defaultBarDuration:[self managedObjectContext]];
    
    TimeSignatureController* timeSigController = [[TimeSignatureController alloc] initWithTimeSignature:nil];
    
    NSManagedObject<TimeSignature>* firstTimeSig = [sortedTimeSignatures objectAtIndex:0];
    
    if ([composition startMarker] < 0)
    {
        if ([sortedTimeSignatures count] > 0 && [[firstTimeSig absoluteTime] longValue] <= 0) {
            [timeSigController setTimeSignature:firstTimeSig];
            barDuration = [timeSigController barDuration];
        }
    }
    
    lastBarNo = [[composition startMarker] longValue] / barDuration;
    lastSigTime = [[composition startMarker] longValue];
    
    id<TimeSignature> aTimeSig;
    
    while(aTimeSig = [timeSigsEnumerator nextObject])
    {
        timeT myTime = [[aTimeSig absoluteTime] longValue];
        int n = (myTime - lastSigTime) / barDuration;
        
        // should only happen for first time sig, when it's at time < 0:
        if (myTime < lastSigTime) --n;
        
        // would there be a new bar here anyway?
        if (barDuration * n + lastSigTime == myTime) { // yes
            n += lastBarNo;
        } else { // no
            n += lastBarNo + 1;
        }
        
        [aTimeSig setBarNumber:[NSNumber numberWithInt:n]];
        
        lastBarNo = n;
        lastSigTime = myTime;
        [timeSigController setTimeSignature:aTimeSig];
        barDuration = [timeSigController barDuration];
        
    }
    
    barPositionsNeedCalculating = NO;
}

- (int) nbBars
{
    [self calculateBarPositions];
    
    int bars = [self barNumber:[self duration] - 1] + 1;
                                
    return bars;
}

- (int) barNumber:(timeT)t
{
    [self calculateBarPositions];
    
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    NSEntityDescription *timeSignatureDescription = [NSEntityDescription entityForName:@"TimeSignature" inManagedObjectContext:moc];
    
    NSFetchRequest *timeSignaturesRequest = [[[NSFetchRequest alloc] init] autorelease];
    [timeSignaturesRequest setEntity:timeSignatureDescription];
    
    // order by absolute time
    //
    [timeSignaturesRequest setSortDescriptors:[[document coreDataUtils] absoluteTimeSortDescriptorArray]];
    
//    NSPredicate *timeSigsBeforeThisTimePredicate = [NSPredicate predicateWithFormat:@"absoluteTime < %@", t];
//    [timeSignaturesRequest setPredicate:timeSigsBeforeThisTimePredicate];
    
    NSError *error = nil;

    int n = 0;
    
    NSArray* timeSigs = [moc executeFetchRequest:timeSignaturesRequest error:&error];
    if (timeSigs != nil) {

        NSUInteger idxOfTimeSigJustBeforeTimeT = NSNotFound;

        if ([timeSigs count] > 0) {
            
            // there are time signatures - find the one right before time t (use reverse enum with this block)
            //
            BOOL (^checkTimeBlock)(id, NSUInteger, BOOL*) = ^ (id obj, NSUInteger idx, BOOL *stop) {
                if ([[obj absoluteTime] longValue] <= t) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            };
                        
            idxOfTimeSigJustBeforeTimeT = [timeSigs indexOfObjectWithOptions:NSEnumerationReverse passingTest:checkTimeBlock];
        }
        
        if (idxOfTimeSigJustBeforeTimeT != NSNotFound) {
            
            // there is a time signature before time t
            NSManagedObject<TimeSignature>* timeSigTimeT = [timeSigs objectAtIndex:idxOfTimeSigJustBeforeTimeT];
            n = [[timeSigTimeT barNumber] intValue];
            timeT offset = t - [[timeSigTimeT absoluteTime] longValue];
            n += offset / [[[TimeSignatureController alloc] initWithTimeSignature:timeSigTimeT] barDuration];
            
        } else {
            
            // no time signatures before time t
            timeT bd;
            
            if (t < 0 && [timeSigs count] > 0) {
                // use the first time sig
                TimeSignatureController* timeSigController = [[TimeSignatureController alloc] initWithTimeSignature:[timeSigs objectAtIndex:0]];
                bd = [timeSigController barDuration];
            } else {
                // use default time signature bar duration
                bd = [TimeSignatureController defaultBarDuration:moc];
            }
            
            n = t / bd;
            
            if (t < 0) {
                // negative bars should be rounded down, except where
                // the time is on a barline in which case we already
                // have the right value (i.e. time -1920 is bar -1,
                // but time -3840 is also bar -1, in 4/4)
                
                if (n * bd != t) {
                    --n;
                }
            }
            
        }
        
    } else {
        NSLog(@"Error when fetching time signatures %@", error);
    }
    
    return n;
}

- (timeT) barStart:(uint)n
{
    return ([self barRange:n]).start;
}

- (timeT) barEnd:(uint)n
{
    return ([self barRange:n]).end;    
}

- (timerange) barRangeForTime:(timeT)t
{
    return [self barRange:[self barNumber:t]];
}

- (timerange) barRange:(uint)n
{
    [self calculateBarPositions];
    
    // find time sig which bar number is just before n
    
    timerange res;
    
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    NSEntityDescription *timeSignatureDescription = [NSEntityDescription entityForName:@"TimeSignature" inManagedObjectContext:moc];
    
    NSFetchRequest *timeSignaturesRequest = [[[NSFetchRequest alloc] init] autorelease];
    [timeSignaturesRequest setEntity:timeSignatureDescription];
    
    // order by absolute time
    //
    [timeSignaturesRequest setSortDescriptors:[[document coreDataUtils] absoluteTimeSortDescriptorArray]];
    
    NSError *error = nil;
    
    NSArray *allTimeSigs = [moc executeFetchRequest:timeSignaturesRequest error:&error];
    if (allTimeSigs != nil) {
    
        if ([allTimeSigs count] > 0) {
            
            // there are time signatures - find the one right after the bar n
            //
            BOOL (^checkBarNumberBlock)(id, NSUInteger, BOOL*) = ^ (id obj, NSUInteger idx, BOOL *stop) {
                if ([[obj barNumber] intValue] > n) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            };
            
            NSUInteger idxOfTimeSigAfterBarN = [allTimeSigs indexOfObjectPassingTest:checkBarNumberBlock];

            NSManagedObject<TimeSignature>* timeSigForBarN = nil;
            NSManagedObject<TimeSignature>* timeSigImmediatelyAfterBarN = nil;

            if (idxOfTimeSigAfterBarN == NSNotFound) {
                // no time sig after bar n - so last time sig is before bar n
                timeSigForBarN = [allTimeSigs lastObject];
                
            } else {
                
                timeSigImmediatelyAfterBarN = [allTimeSigs objectAtIndex:idxOfTimeSigAfterBarN];

                if (idxOfTimeSigAfterBarN > 0) { // there is a preceding time signature
                    timeSigForBarN = [allTimeSigs objectAtIndex:idxOfTimeSigAfterBarN - 1];
                }

            }

            timeT barDuration;

            if (timeSigForBarN != nil) {
                TimeSignatureController* timeSigController = [[TimeSignatureController alloc] initWithTimeSignature:timeSigForBarN];
                barDuration = [timeSigController barDuration];                
                res.start = [[timeSigForBarN absoluteTime] longValue] + (n - [[timeSigForBarN barNumber] intValue]) * barDuration;
            } else {
                barDuration = [TimeSignatureController defaultBarDuration:moc];
                res.start = barDuration * n;
            }

            
            res.end = res.start + barDuration;
            
            // check for partial bar case
            if (timeSigImmediatelyAfterBarN != nil && [[timeSigImmediatelyAfterBarN absoluteTime] longValue] < res.end) {
                res.end = [[timeSigImmediatelyAfterBarN absoluteTime] longValue];
            }
            
            
        } else { // no time sigs
            // bar n precedes any time change
            timeT barDuration = [TimeSignatureController defaultBarDuration:moc];
            res.start = n * barDuration;
            res.end = res.start + barDuration;
        }
        
    } else {
        NSLog(@"Error when fetching time signatures %@", error);
    }
    
    return res;
    
}

- (timeT) duration
{
    // fetch all Elements in reverse order, return absoluteTime of first returned one 
    
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    NSEntityDescription *eventDescription = [NSEntityDescription entityForName:@"Element" inManagedObjectContext:moc];
    
    NSFetchRequest *allEventsRequest = [[[NSFetchRequest alloc] init] autorelease];
    [allEventsRequest setEntity:eventDescription];
    [allEventsRequest setFetchLimit:2]; // we're only interested in the first element
    
    
    NSSortDescriptor* reversedAbsoluteTimeSortDecriptor = [[[[document coreDataUtils] absoluteTimeSortDescriptorArray] objectAtIndex:0] reversedSortDescriptor];
    [allEventsRequest setSortDescriptors:[NSArray arrayWithObject:reversedAbsoluteTimeSortDecriptor]];
    
    NSError *error = nil;
    
    NSArray *allEventsReverse = [moc executeFetchRequest:allEventsRequest error:&error];
    if (allEventsReverse != nil) {
        return [[[allEventsReverse objectAtIndex:0] absoluteTime] longValue];
    }
    
    return 0;
}

- (timeT) timeSignaturesDuration
{
    NSArray* sortedTimeSignatures = [[document timeSignaturesController] arrangedObjects];
    
    if ([sortedTimeSignatures count] > 0) {
        id<TimeSignature> lastTimeSig = [sortedTimeSignatures lastObject];
        return [[lastTimeSig absoluteTime] longValue];
    }
    
    return 0;
}


- (NSUInteger) findNearestTimeInTimeSignatures:(timeT)t
{

    NSUInteger i = [self findTimeInTimeSignatures:t];

    NSArray* sortedTimeSignatures = [[document timeSignaturesController] arrangedObjects];
 
    if (i == ([sortedTimeSignatures count] - 1) || [[[sortedTimeSignatures objectAtIndex:i] absoluteTime] longValue] > t) {
        if (i == 0) {
            return i + 1; // equivalent of end()            
        } else {
            --i;
        }
    }
    return i;
}

// this method cannot return NSNotFound because it uses NSBinarySearchingInsertionIndex, so it returns an insertion point - may return last index (i.e. count() - 1)
- (NSUInteger) findTimeInTimeSignatures:(timeT)t
{
    NSArray* sortedTimeSignatures = [[document timeSignaturesController] arrangedObjects];
    
    [dummyTimeSig setAbsoluteTime:[NSNumber numberWithLong:t]];
    
    NSRange r = NSMakeRange(0, [sortedTimeSignatures count]);
    
    NSComparator timeComparator = ^(id<TimeSignature> obj1, id<TimeSignature> obj2) {
        if ([[obj1 absoluteTime] intValue] > [[obj2 absoluteTime] intValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[obj1 absoluteTime] intValue] < [[obj2 absoluteTime] intValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSUInteger idx = [sortedTimeSignatures indexOfObject:dummyTimeSig inSortedRange:r options:NSBinarySearchingInsertionIndex usingComparator:timeComparator];
    
    return idx;
}

- (timeT) timeSignatureAt:(timeT)t outTimeSignature:(NSManagedObject<TimeSignature>**)timeSig
{
    NSArray* sortedTimeSignatures = [[document timeSignaturesController] arrangedObjects];
    
    NSUInteger i = [self findNearestTimeInTimeSignatures:t];
    
    // from Rosegarden Composition::getTimeSignatureAtAux
    if (t < 0 && i == ([sortedTimeSignatures count] - 1)) {
        i = 0;
        if ([sortedTimeSignatures count] > 0 && [[[sortedTimeSignatures objectAtIndex:0] absoluteTime] longValue] > 0) {
            i = [sortedTimeSignatures count] - 1;
        }
    }
    ///////////////

    if (i == [sortedTimeSignatures count] - 1) {
        *timeSig = [TimeSignatureController defaultTimeSignature:[self managedObjectContext]];
        return 0;
    }
    
    *timeSig = [sortedTimeSignatures objectAtIndex:i];
    return [[*timeSig absoluteTime] longValue];
}

- (NSManagedObject<TimeSignature>*) timeSignatureInBar:(int)barNo isNew:(BOOL*)isNew
{
    NSArray* sortedTimeSignatures = [[document timeSignaturesController] arrangedObjects];
    
    *isNew = NO;
    
    timeT t = [self barRange:barNo].start;
    
    NSUInteger i = [self findNearestTimeInTimeSignatures:t];
    
    // from Rosegarden Composition::getTimeSignatureAtAux
    if (t < 0 && i == ([sortedTimeSignatures count] - 1)) {
        i = 0;
        if ([sortedTimeSignatures count] > 0 && [[[sortedTimeSignatures objectAtIndex:0] absoluteTime] longValue] > 0) {
            i = [sortedTimeSignatures count] - 1;
        }
    }
    ///////////////
 
    if (i == [sortedTimeSignatures count] - 1) {
        return [TimeSignatureController defaultTimeSignature:[self managedObjectContext]];
    }
    
    if ([[[sortedTimeSignatures objectAtIndex:i] absoluteTime] longValue] == t) {
        *isNew = YES;
    }
    
    return [sortedTimeSignatures objectAtIndex:i];
}

@synthesize document;

@end
