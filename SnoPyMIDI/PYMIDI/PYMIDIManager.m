/*
 This software is distributed under the terms of Pete's Public License version 1.0, a
 copy of which is included with this software in the file "License.html".  A copy can
 also be obtained from http://pete.yandell.com/software/license/ppl-1_0.html
 
 If you did not receive a copy of the license with this software, please notify the
 author by sending e-mail to pete@yandell.com
 
 The current version of this software can be found at http://pete.yandell.com/software
 
 Copyright (c) 2002-2004 Peter Yandell.  All Rights Reserved.
 
 $Id: PYMIDIManager.m,v 1.14 2004/01/12 04:39:28 pete Exp $
 
 Update : new URL is http://notahat.com/pymidi
 
*/


#import "PYMIDIManager.h"

#import "PYMIDIUtils.h"
#import "PYMIDIEndpoint.h"
#import "PYMIDIEndpointSet.h"
#import "PYMIDIRealEndpoint.h"
#import "PYMIDIRealSource.h"
#import "PYMIDIRealDestination.h"


@interface PYMIDIManager(private)

- (void)processMIDINotification:(const MIDINotification*)message;

- (void)updateRealSources;
- (PYMIDIEndpoint*)realSourceWithMIDIEndpointRef:(MIDIEndpointRef)midiEndpointRef;
- (void)updateRealDestinations;
- (PYMIDIEndpoint*)realDestinationWithMIDIEndpointRef:(MIDIEndpointRef)midiEndpointRef;

- (void)buildNoteNamesArray;

- (PYMIDIRealEndpoint*)midiObjectAdded:(const MIDIObjectAddRemoveNotification *)message;
- (PYMIDIEndpoint*)midiObjectRemoved:(const MIDIObjectAddRemoveNotification *)message;

@end


@implementation PYMIDIManager


static void midiNotifyProc (const MIDINotification* message, void* refCon);


+ (PYMIDIManager*)sharedInstance
{
    static PYMIDIManager* sharedInstance = nil;
    
    if (sharedInstance == nil) sharedInstance = [[PYMIDIManager alloc] init];
    
    return sharedInstance;
}


- (PYMIDIManager*)init
{
    notificationsEnabled = NO;
    
    NSLog(@"PYMIDIManager:init - MIDIClientCreate");
    MIDIClientCreate (CFSTR("PYMIDIManager"), midiNotifyProc, (__bridge void*)self, &midiClientRef);
    NSLog(@"PYMIDIManager:init - MIDIClientCreate done");
    
    realSourceArray = [[NSMutableArray alloc] init];
    realDestinationArray = [[NSMutableArray alloc] init];
    
    [self updateRealSources];
    [self updateRealDestinations];
    
    [self buildNoteNamesArray];
    
    notificationsEnabled = YES;
    
    return self;
}


- (MIDIClientRef)midiClientRef
{
    return midiClientRef;
}



#pragma mark NOTIFICATION HANDLING


- (void)disableNotifications
{
    notificationsEnabled = NO;
}

- (void)enableNotifications
{
    notificationsEnabled = YES;
}


- (void)processMIDINotification:(const MIDINotification*)message
{
    if (!notificationsEnabled)
        return;
    
    static BOOL isHandlingNotification = NO;
    static BOOL shouldRetryWhenDone    = NO;
    
    if (isHandlingNotification) {
        shouldRetryWhenDone = YES;
        return;
    }
    
    do {
        isHandlingNotification = YES;
        shouldRetryWhenDone    = NO;
        id midiObject;
        NSDictionary *d;
        
        switch (message->messageID) {
            case kMIDIMsgObjectAdded:
                // bug : midiObject is supposed to be a PYMIDIRealEndpoint, extracted by midiOjbectAdded
                // not the case when adding a virtual source
                midiObject = [self midiObjectAdded:(const MIDIObjectAddRemoveNotification *)message];
                d = [NSDictionary dictionaryWithObject:midiObject forKey:PYMIDIAddedRemovedObject];
                [[NSNotificationCenter defaultCenter] postNotificationName:PYMIDIObjectAdded object:self userInfo:d];
                break;

            case kMIDIMsgObjectRemoved:
                midiObject = [self midiObjectRemoved:(const MIDIObjectAddRemoveNotification *)message];
                d = [NSDictionary dictionaryWithObject:midiObject forKey:PYMIDIAddedRemovedObject];
                [[NSNotificationCenter defaultCenter] postNotificationName:PYMIDIObjectRemoved object:self userInfo:d];
                break;
        
            case kMIDIMsgSetupChanged:
                [self updateRealSources];
                [self updateRealDestinations];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:PYMIDISetupChanged object:self];
                break;
                
            case kMIDIMsgPropertyChanged:
                // TODO
                break;
                
            case kMIDIMsgThruConnectionsChanged:
                // TODO
                break;
                
            case kMIDIMsgSerialPortOwnerChanged:
                // TODO
                break;
                
            default:
                NSLog(@"Unknown MIDI notification received");
                //[self broadcastUnknownMIDINotification:message];
                break;
                
        }
        
        isHandlingNotification = NO;
    } while (shouldRetryWhenDone);
}

- (PYMIDIRealEndpoint*)midiObjectAdded:(const MIDIObjectAddRemoveNotification *)message
{
    NSLog(@"MIDI Object added");
    
    PYMIDIRealEndpoint* endpoint = nil;
    
    if (message->childType == kMIDIObjectType_Source) {
        MIDIEndpointRef midiEndpointRef = message->child;
        if (!PYMIDIIsEndpointLocalVirtual (midiEndpointRef)) {
            endpoint = [[PYMIDIRealSource alloc] initWithMIDIEndpointRef:midiEndpointRef];
            [realSourceArray addObject:endpoint];            
        }
    } else if (message->childType == kMIDIObjectType_Destination) {
        MIDIEndpointRef midiEndpointRef = message->child;
        if (!PYMIDIIsEndpointLocalVirtual (midiEndpointRef)) {
            endpoint = [[PYMIDIRealDestination alloc] initWithMIDIEndpointRef:midiEndpointRef];
            [realDestinationArray addObject:endpoint];
        }
    }
    
    return endpoint;
}

- (PYMIDIEndpoint*)midiObjectRemoved:(const MIDIObjectAddRemoveNotification *)message
{
    NSLog(@"MIDI Object removed");

    PYMIDIEndpoint* endpoint = nil;
    
    if (message->childType == kMIDIObjectType_Source) {
        MIDIEndpointRef midiEndpointRef = message->child;
        endpoint = [self realSourceWithMIDIEndpointRef:midiEndpointRef];
        [realSourceArray removeObject:endpoint];            
    } else if (message->childType == kMIDIObjectType_Destination) {
        MIDIEndpointRef midiEndpointRef = message->child;
        endpoint = [self realDestinationWithMIDIEndpointRef:midiEndpointRef];
        [realDestinationArray removeObject:endpoint];
    }
    
    return endpoint;
}

- (void)midiObjectPropertyChanged:(const MIDIObjectPropertyChangeNotification *)message
{
    // TODO
}

- (void)midiThruConnectionsChanged:(const MIDINotification*)message
{
    // TODO
}

- (void)serialPortOwnerChanged:(const MIDINotification*)message
{
    // TODO
}

//- (void)broadcastGenericMIDINotification:(const MIDINotification *)message withName:(NSString *)notificationName;
//{
//    NSDictionary *userInfo;
//    
//    userInfo = [NSDictionary dictionaryWithObject:[NSValue valueWithPointer:message] forKey:PYClientMIDINotificationStruct];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"PYMIDIUnknownNotification" object:self userInfo:userInfo];
//}


static void
midiNotifyProc (const MIDINotification* message, void* refCon)
{
    PYMIDIManager* manager = (__bridge PYMIDIManager*)refCon;
    [manager processMIDINotification:message];
}



#pragma mark REAL MIDI SOURCES


- (void)updateRealSources
{
    NSEnumerator*			enumerator;
    PYMIDIRealEndpoint*		endpoint;
    
    // Sync up all the known MIDI endpoints with CoreMIDI
    enumerator = [realSourceArray objectEnumerator];
    while (endpoint = [enumerator nextObject])
        [endpoint syncWithMIDIEndpoint];
    
    // Find any non-virtual endpoints that we don't already know about
    int i;
    int count = MIDIGetNumberOfSources();
    for (i = 0; i < count; i++) {
        MIDIEndpointRef midiEndpointRef = MIDIGetSource (i);
        
        // If this endpoint is real and previously unknown then add it to our list
        if (!PYMIDIIsEndpointLocalVirtual (midiEndpointRef) &&
            [self realSourceWithMIDIEndpointRef:midiEndpointRef] == nil)
        {
            endpoint = [[PYMIDIRealSource alloc] initWithMIDIEndpointRef:midiEndpointRef];
            [realSourceArray addObject:endpoint];
        }
    }
    
    // Keep our endpoints sorted
    [realSourceArray sortUsingSelector:@selector(compareByDisplayName:)];
}


- (PYMIDIEndpoint*)realSourceWithMIDIEndpointRef:(MIDIEndpointRef)midiEndpointRef
{
    PYMIDIEndpoint* endpoint;
    
    NSEnumerator* enumerator = [realSourceArray objectEnumerator];
    while ((endpoint = [enumerator nextObject]) && [endpoint midiEndpointRef] != midiEndpointRef);
    
    return endpoint;
}


- (NSArray*)realSources
{
    return realSourceArray;
}


- (NSArray*)realSourcesOnlineOrInUse
{
    return [realSourceArray filteredArrayUsingSelector:@selector(isOnlineOrInUse)];
}



- (PYMIDIEndpoint*)realSourceWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor
{
    PYMIDIEndpointSet*	endpointSet;
    PYMIDIEndpoint*		endpoint;
    
    endpointSet = [PYMIDIEndpointSet endpointSetWithArray:realSourceArray];
    endpoint = [endpointSet endpointWithDescriptor:descriptor];
    
    // Create a placeholder if no endpoint matches the descriptor
    if (endpoint == nil) {
        endpoint = [[PYMIDIRealSource alloc] initWithDescriptor:descriptor];
        [realSourceArray addObject:endpoint];
    }
    
    return endpoint;
}



#pragma mark REAL MIDI DESTINATIONS


- (void)updateRealDestinations
{
    NSEnumerator*			enumerator;
    PYMIDIRealEndpoint*		endpoint;
    
    // Sync up all the known MIDI endpoints with CoreMIDI
    enumerator = [realDestinationArray objectEnumerator];
    while (endpoint = [enumerator nextObject])
        [endpoint syncWithMIDIEndpoint];
    
    // Find any non-virtual endpoints that we don't already know about
    int i;
    int count = MIDIGetNumberOfDestinations();
    for (i = 0; i < count; i++) {
        MIDIEndpointRef midiEndpointRef = MIDIGetDestination (i);
        
        // If this endpoint is real and previously unknown then add it to our list
        if (!PYMIDIIsEndpointLocalVirtual (midiEndpointRef) &&
            [self realDestinationWithMIDIEndpointRef:midiEndpointRef] == nil)
        {
            endpoint = [[PYMIDIRealDestination alloc] initWithMIDIEndpointRef:midiEndpointRef];
            [realDestinationArray addObject:endpoint];
        }
    }
    
    // Keep our endpoints sorted
    [realDestinationArray sortUsingSelector:@selector(compareByDisplayName:)];
}


- (PYMIDIEndpoint*)realDestinationWithMIDIEndpointRef:(MIDIEndpointRef)midiEndpointRef
{
    PYMIDIEndpoint* endpoint;
    
    NSEnumerator* enumerator = [realDestinationArray objectEnumerator];
    while ((endpoint = [enumerator nextObject]) && [endpoint midiEndpointRef] != midiEndpointRef);
    
    return endpoint;
}


- (NSArray*)realDestinations
{
    return realDestinationArray;
}


- (NSArray*)realDestinationsOnlineOrInUse
{
    return [realDestinationArray filteredArrayUsingSelector:@selector(isOnlineOrInUse)];
}



- (PYMIDIEndpoint*)realDestinationWithDescriptor:(PYMIDIEndpointDescriptor*)descriptor
{
    PYMIDIEndpointSet*	endpointSet;
    PYMIDIEndpoint*		endpoint;
    
    endpointSet = [PYMIDIEndpointSet endpointSetWithArray:realDestinationArray];
    endpoint = [endpointSet endpointWithDescriptor:descriptor];
    
    // Create a placeholder if no endpoint matches the descriptor
    if (endpoint == nil) {
        endpoint = [[PYMIDIRealDestination alloc] initWithDescriptor:descriptor];
        [realDestinationArray addObject:endpoint];
    }
    
    return endpoint;
}



#pragma mark NOTE NAMES


- (void)buildNoteNamesArray
{
    NSMutableArray* tempNoteNamesArray;
    
    int i, octave, note;
    char* noteName[] = {
        "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
    };
    
    tempNoteNamesArray = [NSMutableArray arrayWithCapacity:128];
    
    for (i = 0; i < 128; i++) {
        octave = i / 12;
        note   = i % 12;
        
        [tempNoteNamesArray addObject:[NSString stringWithFormat:@"%s%d", noteName[note], octave-1]];
    }
    
    noteNamesArray = [[NSArray alloc] initWithArray:tempNoteNamesArray];
}


- (NSString*)nameOfNote:(Byte)note
{
    return [noteNamesArray objectAtIndex:note];
}


NSString* PYMIDIObjectAdded = @"PYMIDIObjectAdded";
NSString* PYMIDIObjectRemoved = @"PYMIDIObjectRemoved";
NSString* PYMIDISetupChanged = @"PYMIDISetupChanged";

NSString* PYMIDIAddedRemovedObject = @"PYMIDIAddedRemovedObject";


@end