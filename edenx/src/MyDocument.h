//
//  MyDocument.h
//  orchard
//
//  Created by Guillaume Laurent on 4/13/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>

#import "SynchroScrollView.h"
#import "CoreDataUtils.h"

@class TrackEditor;
@class Player;
@class NSManagedObject;
@class TracksController;
@class CompositionController;
@class SegmentCanvas;

@interface MyDocument : NSPersistentDocument {
    IBOutlet SynchroScrollView* trackListView;
    IBOutlet NSScrollView* trackCanvasView;
    IBOutlet TracksController* tracksController;
    IBOutlet NSArrayController* timeSignaturesController;
    IBOutlet NSArrayController* temposController;
    IBOutlet CompositionController* compositionController;
    IBOutlet CoreDataUtils* coreDataUtils;
    IBOutlet SegmentCanvas* segmentCanvas;
    TrackEditor* trackEditor;
    // cursor position
    Player* player;
    MusicSequence sequence;
    BOOL documentModifiedSinceLastPlay;
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

- (void)setupZoomSlider;

// this property actually comes from the Player, see implementation
@property(readonly) BOOL playing;

@property(readonly) TracksController* tracksController;
@property(readonly) CompositionController* compositionController;
@property(readonly) NSArrayController* timeSignaturesController;
@property(readonly) NSArrayController* temposController;
@property(readonly) MusicSequence sequence;
@property(readonly) CoreDataUtils* coreDataUtils;
@property(readonly) SegmentCanvas* segmentCanvas;

@end
