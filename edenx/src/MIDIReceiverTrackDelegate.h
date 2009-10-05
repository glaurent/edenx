//
//  MIDIReceiverTrackDelegate.h
//  edenx
//
//  Created by Guillaume Laurent on 9/20/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MIDIReceiver.h"
#import "CoreDataStuff.h"

// delegate for MIDIReceiver, job is to add to a track the SMMessages
// converted to events
//
@interface MIDIReceiverTrackDelegate : NSObject <MIDIReceiverDelegate> {

    int idx;
    id table[0xf * 0xff];
    NSManagedObject<Track>* track;
    MIDITimeStamp recordingStartTime;
}

static const unsigned int tablesize = 0xf * 0xff;

- (id)initWithTrack:(NSManagedObject<Track>*)aTrack withStartTime:(MIDITimeStamp)startTime;

- (void)didReceiveMessage:(NSArray *)messages count:(unsigned int)count;

- (void)reset;

@end
