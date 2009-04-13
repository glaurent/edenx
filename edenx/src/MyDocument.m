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

@implementation MyDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
        player = [[Player alloc] init];
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
    NSLog(@"editSelectedTrack");
    
    if (!trackEditor) {
        NSLog(@"editSelectedTrack : allocating track editor");
        trackEditor = [[TrackEditor alloc] init];
    }
    
    NSLog(@"showing track editor %@", trackEditor);
    
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
    [player setUp:[self managedObjectContext]];
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


@end
