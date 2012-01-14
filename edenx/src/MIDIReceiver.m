//
//  MIDIReceiver.m
//  PyMIDITest
//
//  Created by Guillaume Laurent on 7/16/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "MIDIReceiver.h"
#import "SMMessage.h"
#import "SMMessageParser.h"


@implementation MIDIReceiver

@synthesize messages;
@synthesize delegate;

- (id)init
{
    if (!(self = [super init]))
        return nil;

    parser = [[SMMessageParser alloc] init];
    messages = [NSMutableArray arrayWithCapacity:10];
    delegate = nil;
    [parser setDelegate:self];
    
    return self;
}

- (void)clearMessages
{
    [messages removeAllObjects];
}

- (void)processMIDIPacketList:(MIDIPacketList*)myPacketList sender:(id)sender
{
    NSLog(@"MIDIReceiver : got MIDI data from %@", sender);
    
    [parser setOriginatingEndpoint:sender];
    [parser takePacketList:myPacketList];
}

- (void)parser:(SMMessageParser *)parser didReadMessages:(NSArray *)msgs
{
    NSLog(@"MIDIReceiver : did read %lu messages", [msgs count]);
    [messages addObjectsFromArray:msgs];
    if (delegate) {
        [delegate didReceiveMessage:messages count:[msgs count]];
    }
}

- (void)parser:(SMMessageParser *)parser isReadingSysExWithLength:(unsigned int)length
{
    // anything to do here ?
}

- (void)parser:(SMMessageParser *)parser finishedReadingSysExMessage:(SMSystemExclusiveMessage *)message
{
    [messages addObject:message];
}

@end
