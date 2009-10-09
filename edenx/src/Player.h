//
//  Player.h
//  edenx
//
//  Created by Guillaume Laurent on 4/11/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Player : NSObject {
    MusicSequence sequence;
    MusicPlayer player;
    BOOL isSetup;
    OSStatus lastError;
}

- (id)init;
- (void)setUpWithSequence:(MusicSequence)seq;
- (void)setupAUGraph;
- (void)play;
- (void)stop;
- (void)rewind;
- (BOOL)isPlaying;

@property(readonly) OSStatus lastError;

@end
