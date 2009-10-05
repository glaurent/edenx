//
//  Player.h
//  edenx
//
//  Created by Guillaume Laurent on 4/11/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <AudioToolbox/AudioToolbox.h>

@interface Player : NSObject {
    MusicSequence sequence;
    MusicPlayer player;
    BOOL isSetup;
    OSStatus lastError;
}

@property(readonly) OSStatus lastError;

- (id)init;
- (void)setUpAndFillWithSequence:(NSManagedObjectContext*)managedObjectContext;
- (void)setupAUGraph;
- (void)fillSequence:(NSManagedObjectContext*)managedObjectContext;
- (void)play;
- (void)stop;
- (void)rewind;
- (BOOL)isPlaying;

@end
