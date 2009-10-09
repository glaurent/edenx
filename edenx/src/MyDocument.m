//
//  MyDocument.m
//  orchard
//
//  Created by Guillaume Laurent on 4/13/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "MyDocument.h"

#import "PlaybackCursorView.h"
#import "TrackEditor.h"
#import "Player.h"
#import "SMMessage.h"
#import "MIDIReceiver.h"
#import "AppController.h"
#import "Recorder.h"
#import "CoreDataStuff.h"

#import <CoreAudio/CoreAudioTypes.h>

@interface MyDocument (private)

- (void)setupTempo;
- (void)fillSequence;

@end


@implementation MyDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
        player = [(AppController*)[NSApp delegate] player];
        NewMusicSequence(&sequence);
    }
    return self;
}

- (NSString *)windowNibName 
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];

    // synchronize track list and track canvas scroll views
    [trackListView setSynchronizedScrollView:trackCanvasView];
        
}


- (IBAction)showPlayBackCursor:(id)sender
{
    NSLog(@"showPlayBackCursor : %d", [sender state]);
    
    [playbackCursorView setHidden:([sender state] == NSOffState)];
}

- (IBAction)editSelectedTrack:(id)sender
{
    if (!trackEditor) {
        NSLog(@"editSelectedTrack : allocating track editor");
        trackEditor = [[TrackEditor alloc] initWithCurrentDocument:self];
    }
    
    [trackEditor showWindow:self];
}

- (IBAction)togglePlay:(id)sender
{
    if ([player isPlaying])
        [self stop:self];
    else
        [self play:self];
}

- (IBAction)play:(id)sender
{
    NSLog(@"start playing");
    [self fillSequence];
    [player setUpWithSequence:sequence];
    [player play];
}

- (IBAction)stop:(id)sender
{
    [player stop];
    NSLog(@"stop playing"); 
}

- (BOOL)playing
{
    return [player isPlaying];
}


- (IBAction)rewind:(id)sender
{
    [player rewind];
}

- (NSArrayController*)midiSourcesController
{
    Recorder* recorder = [(AppController*)[NSApp delegate] recorder];
    return [recorder midiSourcesController];
}

- (IBAction)toggleRecording:(id)sender
{
    NSLog(@"toggle recording");

    Recorder* recorder = [(AppController*)[NSApp delegate] recorder];

    if ([sender state] == NSOnState) {
        NSLog(@"MyDocument : start recording");
        [self setupTempo];
        [recorder start];
    } else {
        [recorder stop];
    }
}


- (IBAction)testAddEvent:(id)sender
{
    NSManagedObject* currentTrack = [[tracksController selectedObjects] objectAtIndex:0];
    
    NSManagedObjectContext* managedObjectContext = [currentTrack managedObjectContext];
    
    NSManagedObject<Note>* newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" 
                                                             inManagedObjectContext:managedObjectContext];
    
//    NSLog(@"MyDocument:testAddEvent note = %@", newNote);
//    NSLog(@"MyDocument:testAddEvent note duration = %@, pitch = %@", [newNote duration], [newNote note]);
    
    UInt64 d = AudioConvertNanosToHostTime(1000000000);
    
    [newNote setDuration:[NSNumber numberWithUnsignedLong:d]];
    [newNote setNote:[NSNumber numberWithInt:60]];
    [newNote setVelocity:[NSNumber numberWithInt:120]];
    
    [currentTrack addEventsObject:newNote];

}

- (void)setupTempo
{
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    // Get tempo from composition
    NSEntityDescription *compositionEntityDescription = [NSEntityDescription entityForName:@"Composition" inManagedObjectContext:moc];
    NSFetchRequest *compositionRequest = [[[NSFetchRequest alloc] init] autorelease];
    [compositionRequest setEntity:compositionEntityDescription];    
    
    NSError *error = nil;
    NSArray *composition = [moc executeFetchRequest:compositionRequest error:&error];
    
    id<Composition> theComposition = [composition objectAtIndex:0];
    
    NSNumber* f = [theComposition tempo];
    
    NSLog(@"MyDocument:setupTempo : tempo = %@", f);
    
    MusicTrack tempoTrack;
    
    MusicSequenceGetTempoTrack(sequence, &tempoTrack);
    
    MusicTrackClear(tempoTrack, 0.0, 1.0); // clear first tempo event, if any
    
    MusicTrackNewExtendedTempoEvent(tempoTrack, 0.0, [f doubleValue]);
    
}

- (void)fillSequence {
    NSLog(@"MyDocument:fillSequence");

    [self setupTempo];
    
    NSManagedObjectContext* moc = [self managedObjectContext];

    NSEntityDescription *trackEntityDescription = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:moc];
    
    NSFetchRequest *tracksRequest = [[[NSFetchRequest alloc] init] autorelease];
    [tracksRequest setEntity:trackEntityDescription];    
    
    NSError *error = nil;
    NSArray *tracks = [moc executeFetchRequest:tracksRequest error:&error];
    if (tracks != nil) {
        NSEnumerator *tracksEnumerator = [tracks objectEnumerator];
        
        id aTrack;
        
        while(aTrack = [tracksEnumerator nextObject]) {
            MusicTrack sequenceTrack;
            MusicSequenceNewTrack(sequence, &sequenceTrack);
            
            
            // Fetch all playable events from that track
            NSEntityDescription *playableEventDescription = [NSEntityDescription entityForName:@"PlayableElement" inManagedObjectContext:moc];
            
            NSFetchRequest *playableEventsRequest = [[[NSFetchRequest alloc] init] autorelease];
            [playableEventsRequest setEntity:playableEventDescription];
            
            // I could get the events directly from aTrack, but with a query I get the filtering of playable events for free
            //
            NSPredicate *eventsFromThisTrackPredicate = [NSPredicate predicateWithFormat:@"track == %@", aTrack];
            [playableEventsRequest setPredicate:eventsFromThisTrackPredicate];
            NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"absoluteTime" ascending:YES];            
            [playableEventsRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            NSArray *playableEvents = [moc executeFetchRequest:playableEventsRequest error:&error];
            if (playableEvents != nil) {
                NSEnumerator *eventsEnumerator = [playableEvents objectEnumerator];
                
                NSLog(@"got %d playable events for track '%@'", [playableEvents count], [aTrack name]);
                
                NSManagedObject<Element,Note>* anEvent;
                
                while(anEvent = [eventsEnumerator nextObject]) {
                    // NSLog(@"event : %@ ", anEvent);
                    MIDINoteMessage msg;
                    msg.channel = [[aTrack channel] intValue];
                    msg.duration = [[anEvent duration] floatValue];
                    msg.velocity = [[anEvent velocity] intValue];
                    msg.note = [[anEvent note] intValue];
                    MusicTimeStamp timeStamp = [[anEvent absoluteTime] doubleValue];
                    MusicTrackNewMIDINoteEvent(sequenceTrack, timeStamp, &msg);
                }
            } else {
                NSLog(@"error when fetching events for track");
            }
        }
        
    } else {
        NSLog(@"error when fetching track");
    }
    
    NSLog(@"CAShow sequence :");
    CAShow(sequence);
}



@synthesize tracksController;
@synthesize sequence;

@end
