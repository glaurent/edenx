//
//  TracksController.h
//  edenx
//
//  Created by Guillaume Laurent on 9/20/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TracksController : NSArrayController {
    NSPredicate *inputSourceSetPredicate;
}

// returns the lists of tracks which have a recording source set
- (NSArray*)recordingTracks;

@end
