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

@implementation MyDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
        player = [(AppController*)[NSApp delegate] player];
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
    [player setUpAndFillWithSequence:[self managedObjectContext]];
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




@synthesize tracksController;

@end
