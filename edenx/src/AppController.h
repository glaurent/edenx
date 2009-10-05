//
//  AppController.h
//  edenx
//
//  Created by Guillaume Laurent on 2/15/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MIDIReceiver;
@class Recorder;
@class Player;

@interface AppController : NSObject {
    IBOutlet Recorder* recorder;
    Player* player;
}

- (id)init;


@property (readonly) Recorder* recorder;
@property (readonly) Player* player;

@end
