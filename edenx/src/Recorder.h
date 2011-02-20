//
//  Recorder.h
//  edenx
//
//  Created by Guillaume Laurent on 9/12/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Recorder : NSObject {
    NSMapTable* midiReceiversToEndPointsTable;
    NSMutableArray* midiSources;
    IBOutlet NSArrayController* midiSourcesController;    

    BOOL recording;
    MIDITimeStamp recordingStartTime;
    
    BOOL disableSound;
    
}

- (id)init;
- (void)setup;
- (void)start;
- (void)stop;

- (void)handleMIDIAddObject:(NSNotification*)notification;
- (void)handleMIDIRemoveObject:(NSNotification*)notification;

@property (readonly) NSMutableArray* midiSources;
@property (readonly) NSArrayController* midiSourcesController;
@property (readonly) BOOL recording;
@property (readonly) MIDITimeStamp recordingStartTime;
@property (readwrite) BOOL disableSound;

@end
