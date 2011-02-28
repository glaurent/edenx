//
//  MIDIReceiverTrackDelegate.h
//  edenx
//
//  Created by Guillaume Laurent on 9/20/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MIDIReceiver.h"
#import "CoreDataStuff.h"

static const unsigned int tablesize = 0xf * 0xff;

// delegate for MIDIReceiver, job is to add to a track the SMMessages
// converted to events
//
@interface MIDIReceiverTrackDelegate : NSObject <MIDIReceiverDelegate> {

    int idx;
    id table[0xf * 0xff];
    NSManagedObject<Segment>* segment;
    MIDITimeStamp recordingStartTime;
    Float64 recordingStartTimeInSeconds;
    MusicSequence sequence; // used to convert events time
}

- (id)initWithTrack:(NSManagedObject<Segment>*)aTrack withStartTime:(MIDITimeStamp)startTime withMusicSequence:(MusicSequence)aSeq;

- (void)didReceiveMessage:(NSArray *)messages count:(unsigned int)count;

- (void)reset;

@end
