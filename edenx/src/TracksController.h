//
//  TracksController.h
//  edenx
//
//  Created by Guillaume Laurent on 9/20/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TracksController : NSArrayController {
    NSPredicate *inputSourceSetAndRecordingPredicate;
    NSPredicate *inputSourceSetPredicate;
}

- (id)initWithContent:(id)content;
- (id)init;


// returns the lists of tracks which have an input source set and recording toggled on
- (NSArray*)recordingTracks;

// same, but with input source set only
- (NSArray*)inputSourceSetTracks;

- (void)handleMIDIRemoveObject:(NSNotification*)notification;

@end
