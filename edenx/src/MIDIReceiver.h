//
//  MIDIReceiver.h
//  PyMIDITest
//
//  Created by Guillaume Laurent on 7/16/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>

#import "SMMessageParser.h"


@protocol MIDIReceiverDelegate

- (void)didReceiveMessage:(NSArray*)messages count:(unsigned int)count;

@end

@interface MIDIReceiver : NSObject <SMMessageParserDelegate> {
    SMMessageParser* parser;
    NSMutableArray*  messages;
    id<MIDIReceiverDelegate> delegate;
}

- (id)init;

- (void)processMIDIPacketList:(MIDIPacketList*)myPacketList sender:(id)sender;
- (void)clearMessages;


@property (readonly) NSMutableArray* messages;
@property (readwrite) id delegate;


// SMMessageParserDelegate implementation
//
- (void)parser:(SMMessageParser *)parser didReadMessages:(NSArray *)messages;
- (void)parser:(SMMessageParser *)parser isReadingSysExWithLength:(unsigned int)length;
- (void)parser:(SMMessageParser *)parser finishedReadingSysExMessage:(SMSystemExclusiveMessage *)message;


@end

