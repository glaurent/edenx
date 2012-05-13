//
//  MyDocument.h
//  orchard
//
//  Created by Guillaume Laurent on 4/13/08.
//  Copyright telegraph-road.org 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>

#import "SynchroScrollView.h"
#import "CoreDataUtils.h"
#import "CoreDataStuff.h"

@class SegmentEditor;
@class SegmentNotationEditor;
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
    IBOutlet NSArrayController* segmentsController;
    SegmentEditor* segmentEventListEditor;
    SegmentNotationEditor* segmentNotationEditor;
    // cursor position
    Player* player;
    MusicSequence sequence;
    BOOL documentModifiedSinceLastPlay;
    BOOL firstDocumentModif;
}

- (IBAction)showPlayBackCursor:(id)sender;
- (IBAction)editSelectedSegmentEventList:(id)sender;
- (IBAction)editSelectedSegmentNotation:(id)sender;
- (IBAction)togglePlay:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)rewind:(id)sender;
- (IBAction)toggleRecording:(id)sender;

- (IBAction)testAddEvent:(id)sender;

- (NSArrayController*)midiSourcesController;

- (void)setupZoomSlider;

- (NSManagedObject<Segment>*)createSegmentInTrack:(NSManagedObject<Track>*)track startingAtTime:(double)startTime endingAtTime:(double)endTime;
- (void)deleteSegment:(NSManagedObject<Segment>*)segment;

// this property actually comes from the Player, see implementation
@property(readonly) BOOL playing;

@property(readonly) TracksController* tracksController;
@property(readonly) NSArrayController* segmentsController;
@property(readonly) CompositionController* compositionController;
@property(readonly) NSArrayController* timeSignaturesController;
@property(readonly) NSArrayController* temposController;
@property(readonly) MusicSequence sequence;
@property(readonly) CoreDataUtils* coreDataUtils;
@property(readonly) SegmentCanvas* segmentCanvas;

@end
