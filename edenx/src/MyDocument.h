//
//  MyDocument.h
//  orchard
//
//  Created by Guillaume Laurent on 4/13/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SynchroScrollView.h"

@class TrackEditor;
@class Player;
@class NSManagedObject;
@class TracksController;

@interface MyDocument : NSPersistentDocument {
    IBOutlet NSView* playbackCursorView;
    IBOutlet SynchroScrollView* trackListView;
    IBOutlet NSScrollView* trackCanvasView;
    IBOutlet TracksController* tracksController;
    TrackEditor* trackEditor;
    // cursor position
    Player* player;
    
}

- (IBAction)showPlayBackCursor:(id)sender;
- (IBAction)editSelectedTrack:(id)sender;
- (IBAction)togglePlay:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)rewind:(id)sender;
- (IBAction)toggleRecording:(id)sender;

- (IBAction)testAddEvent:(id)sender;

- (NSArrayController*)midiSourcesController;

// this property actually comes from player, see getter
@property(readonly) BOOL playing;

@property(readonly) TracksController* tracksController;

@end
