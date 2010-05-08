//
//  TimeSignatureController.m
//  edenx
//
//  Created by Guillaume Laurent on 3/18/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//  Copyright 2000-2009 the Rosegarden development team.
//

#import "TimeSignatureController.h"
#import "Note.h"
#import "CoreDataStuff.h"

// static const unsigned int basePPQ = 960; // won't work with the other definitions below because of a silly compiler bug or limitation
#define basePPQ 960
static const unsigned int crotchetTime = basePPQ;
static const unsigned int dottedCrotchetTime = basePPQ + basePPQ / 2;

static NSManagedObject<TimeSignature>* defaultTimeSignature44 = 0;

@implementation TimeSignatureController

+ (timeT)defaultBarDuration:(NSManagedObjectContext*)managedObjectContext
{
    static TimeSignatureController* defaultTimeSignatureController = 0;
    
    if (!defaultTimeSignature44) {
        [TimeSignatureController createDefaultTimeSignature:managedObjectContext];        
    }
    
    if (!defaultTimeSignatureController) {
        defaultTimeSignatureController = [[TimeSignatureController alloc] initWithTimeSignature:defaultTimeSignature44];
    }
    
    return [defaultTimeSignatureController barDuration];
}

+ (void)createDefaultTimeSignature:(NSManagedObjectContext*)managedObjectContext
{
    if (defaultTimeSignature44)
        return;

    defaultTimeSignature44 = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSignature" 
                                                           inManagedObjectContext:managedObjectContext];
    
    
    [defaultTimeSignature44 setNumerator:[NSNumber numberWithUnsignedInt:4]];
    [defaultTimeSignature44 setDenominator:[NSNumber numberWithUnsignedInt:4]];
    [defaultTimeSignature44 setCommon:[NSNumber numberWithInt:1]];
    
}

+ (NSManagedObject<TimeSignature>*)defaultTimeSignature:(NSManagedObjectContext*)managedObjectContext
{
    [TimeSignatureController createDefaultTimeSignature:managedObjectContext];
    
    return defaultTimeSignature44;
}

- (id)initWithTimeSignature:(NSManagedObject<TimeSignature>*)t
{
    self = [super init];

    timeSignature = t;
    durationsSet = NO;
    
    return self;
}

- (void)setTimeSignature:(NSManagedObject<TimeSignature>*)t
{
    timeSignature = t;
    durationsSet = NO;
}

- (timeT)unitDuration
{
    return crotchetTime * 4 / [[timeSignature denominator] intValue];
}

- (BOOL)dotted
{
    [self setInternalDurations];
    return dotted;
}

- (timeT)barDuration
{
    [self setInternalDurations];
    return barDuration;
}

- (timeT)beatDuration
{
    [self setInternalDurations];
    return beatDuration;
}

- (uint)beatsPerBar
{
    [self setInternalDurations];
    return barDuration / beatDuration;
}

- (void)addDurationListForBarInArray:(NSMutableArray*)array
{
    
    // If the bar's length can be represented with one long symbol, do it.
    // Otherwise, represent it as individual beats.
    
    if (barDuration == crotchetTime ||
        barDuration == crotchetTime * 2 ||
        barDuration == crotchetTime * 4 ||
        barDuration == crotchetTime * 8 ||
        barDuration == dottedCrotchetTime ||
        barDuration == dottedCrotchetTime * 2 ||
        barDuration == dottedCrotchetTime * 4 ||
        barDuration == dottedCrotchetTime * 8) {
        
        [array addObject:[NSNumber numberWithInt:barDuration]];
        
    } else {
        
        for (int i = 0; i < [self beatsPerBar]; ++i) {
            [array addObject:[NSNumber numberWithInt:beatDuration]];
        }
        
    }
}

// This doesn't consider subdivisions of the bar larger than a beat in
// any time other than 4/4, but it should handle the usual time signatures
// correctly (compound time included).
- (void)addDurationListForInterval:(uint)duration withStartOffset:(uint)startOffset inArray:(NSMutableArray*)durations
{
    [self setInternalDurations];
    
    uint offset = startOffset;
    uint durationRemaining = duration;
    
    while (durationRemaining > 0) {
        
        // Everything in this loop is of the form, "if we're on a
        // [unit] boundary and there's a [unit] of space left to fill,
        // insert a [unit] of time."
        
        // See if we can insert a bar of time.
        
        if (offset % barDuration == 0
            && durationRemaining >= barDuration) {
            
            [self addDurationListForBarInArray:durations];
            durationRemaining -= barDuration,
            offset += barDuration;
            
        }
        
        // If that fails and we're in 4/4 time, see if we can insert a
        // half-bar of time.
        
        //_else_ if!
        else if ([[timeSignature numerator] intValue] == 4 && [[timeSignature denominator] intValue] == 4
                 && offset % (barDuration/2) == 0
                 && durationRemaining >= barDuration/2) {
            
            [durations addObject: [NSNumber numberWithInt:barDuration/2]];
            durationRemaining -= barDuration/2;
            offset += barDuration;
            
        }
        
        // If that fails, see if we can insert a beat of time.
        
        else if (offset % beatDuration == 0
                 && durationRemaining >= beatDuration) {
            
            [durations addObject:[NSNumber numberWithInt:beatDuration]];
            durationRemaining -= beatDuration;
            offset += beatDuration;
            
        }
        
        // If that fails, see if we can insert a beat-division of time
        // (half the beat in simple time, a third of the beat in compound
        // time)
        
        else if (offset % beatDivisionDuration == 0
                 && durationRemaining >= beatDivisionDuration) {
            
            [durations addObject:[NSNumber numberWithInt:beatDivisionDuration]];
            durationRemaining -= beatDivisionDuration;
            offset += beatDivisionDuration;
            
        }
        
        // cc: In practice, if the time we have remaining is shorter
        // than our shortest note then we should just insert a single
        // unit of the correct time; we won't be able to do anything
        // useful with any shorter units anyway.
        
        else if (durationRemaining <= [[Note noteWithType:Shortest] duration]) {
            
            [durations addObject:[NSNumber numberWithInt:durationRemaining]];
            offset += durationRemaining;
            durationRemaining = 0;
            
        }
        
        // If that fails, keep halving the beat division until we
        // find something to insert. (This could be part of the beat-division
        // case; it's only in its own place for clarity.)
        
        else {
            
            uint currentDuration = beatDivisionDuration;
            
            while ( !(offset % currentDuration == 0
                      && durationRemaining >= currentDuration) ) {
                
                if (currentDuration <= [[Note noteWithType:Shortest] duration]) {
                    
                    // okay, this isn't working.  If our duration takes
                    // us past the next beat boundary, fill with an exact
                    // rest duration to there and then continue  --cc
                    
                    uint toNextBeat =
                    beatDuration - (offset % beatDuration);
                    
                    if (durationRemaining > toNextBeat) {
                        currentDuration = toNextBeat;
                    } else {
                        currentDuration  = durationRemaining;
                    }
                    break;
                }
                
                currentDuration /= 2;
            }
            
            [durations addObject:[NSNumber numberWithInt:currentDuration]];
            durationRemaining -= currentDuration;
            offset += currentDuration;
            
        }
        
    }

}

- (uint)emphasisForTime:(timeT)offset
{
    [self setInternalDurations];
    
    if      (offset % barDuration == 0)
        return 4;
    else if ([[timeSignature numerator] intValue] == 4 && [[timeSignature denominator] intValue] == 4 &&
             offset % (barDuration/2) == 0)
        return 3;
    else if (offset % beatDuration == 0)
        return 2;
    else if (offset % beatDivisionDuration == 0)
        return 1;
    else
        return 0;
    
}

- (void)addDivisions:(uint)depth inArray:(NSMutableArray*)divisions
{
    if (depth <= 0) return;
    uint base = [self barDuration]; // calls setInternalDurations
    /*
     if (m_numerator == 4 && m_denominator == 4) {
     divisions.push_back(2);
     base /= 2;
     --depth;
     }
     */
    if (depth <= 0) return;
    
    [divisions addObject:[NSNumber numberWithInt:(base / beatDuration)]];
    base = beatDuration;
    --depth;
    
    if (depth <= 0) return;
    
    if (dotted) [divisions addObject:[NSNumber numberWithInt:3]];
    else [divisions addObject:[NSNumber numberWithInt:2]];
    --depth;
    
    while (depth > 0) {
        [divisions addObject:[NSNumber numberWithInt:2]];
        --depth;
    }
    
    
}

- (void)setInternalDurations
{
    if (durationsSet)
        return;
    
    uint numerator = [[timeSignature numerator] intValue];
    uint denominator = [[timeSignature denominator] intValue];
    
    int unitLength = crotchetTime * 4 / denominator;
    
    barDuration = numerator * unitLength;
    
    // Is 3/8 dotted time?  This will report that it isn't, because of
    // the check for m_numerator > 3 -- but otherwise we'd get a false
    // positive with 3/4
    
    // [rf] That's an acceptable answer, according to my theory book. In
    // practice, you can say it's dotted time iff it has 6, 9, or 12 on top.
    
    dotted = (numerator % 3 == 0 &&
              numerator > 3 &&
              barDuration >= dottedCrotchetTime);
    
    if (dotted) {
        beatDuration = unitLength * 3;
        beatDivisionDuration = unitLength;
    }
    else {
        beatDuration = unitLength;
        beatDivisionDuration = unitLength / 2;
    }
    
    
}

@end
