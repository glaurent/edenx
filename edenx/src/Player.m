//
//  Player.m
//  edenx
//
//  Created by Guillaume Laurent on 4/11/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "Player.h"
#import "CoreDataStuff.h"

@implementation Player

- (id)init {
    self = [super init];
    if (self != nil) {
        NewMusicPlayer(&player);
        isSetup = NO;
    }
    
    return self;
}

- (void)finalize
{
    DisposeMusicSequence(sequence);
    DisposeMusicPlayer(player);
    [super finalize];
}

- (OSStatus)lastError {
    return lastError;
}

- (void)setLastError:(OSStatus)newLastError {
    if (newLastError != 0)
        NSLog(@"Player error : %d", newLastError);
    
    lastError = newLastError;
}

- (void)setUp:(NSManagedObjectContext*)managedObjectContext {
    NSLog(@"Player:setUp");
    
    if (!isSetup) {
        NewMusicSequence(&sequence);
        
        [self fillSequence:managedObjectContext];
        
        [self setLastError:MusicPlayerSetSequence(player, sequence)];
        
        [self setupAUGraph];
        
        // isSetup = YES;
    }

}

OSStatus SetUpGraph (AUGraph inGraph, UInt32 numFrames, Float64 sampleRate, bool isOffline);
OSStatus GetSynthFromGraph (AUGraph inGraph, AudioUnit outSynth);

- (void)setupAUGraph {
    AUGraph graph = 0;
    AudioUnit theSynth = 0;
    OSStatus result;
    Float32 maxCPULoad = .8;
	Float64 srate = 0;
	const char* outputFilePath = 0;
	
	// Float32 startTime = 0;
	UInt32 numFrames = 512;
    
    MusicSequenceGetAUGraph(sequence, &graph);
    AUGraphOpen(graph);
    
    
    result = GetSynthFromGraph(graph, theSynth);
    result = AudioUnitSetProperty(theSynth,
                                  kAudioUnitProperty_CPULoad,
                                  kAudioUnitScope_Global, 0,
                                  &maxCPULoad, sizeof(maxCPULoad));

    SetUpGraph (graph, numFrames, srate, (outputFilePath != NULL));
    
    result = AUGraphInitialize (graph);
    
}



- (void)fillSequence:(NSManagedObjectContext*)moc {
    NSLog(@"Player:fillSequence");
    
    NSEntityDescription *trackEntityDescription = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:moc];

    NSFetchRequest *tracksRequest = [[[NSFetchRequest alloc] init] autorelease];
    [tracksRequest setEntity:trackEntityDescription];    
    
    NSError *error = nil;
    NSArray *tracks = [moc executeFetchRequest:tracksRequest error:&error];
    if (tracks != nil) {
        NSEnumerator *tracksEnumerator = [tracks objectEnumerator];
        
        id aTrack;
        
        while(aTrack = [tracksEnumerator nextObject]) {
            MusicTrack sequenceTrack;
            MusicSequenceNewTrack(sequence, &sequenceTrack);

            
            // Fetch all playable events from that track
            NSEntityDescription *playableEventDescription = [NSEntityDescription entityForName:@"PlayableElement" inManagedObjectContext:moc];
            
            NSFetchRequest *playableEventsRequest = [[[NSFetchRequest alloc] init] autorelease];
            [playableEventsRequest setEntity:playableEventDescription];
            
            // I could get the events directly from aTrack, but with a query I get the filtering of playable events for free
            //
            NSPredicate *eventsFromThisTrackPredicate = [NSPredicate predicateWithFormat:@"track == %@", aTrack];
            [playableEventsRequest setPredicate:eventsFromThisTrackPredicate];
            NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"absoluteTime" ascending:YES];            
            [playableEventsRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            NSArray *playableEvents = [moc executeFetchRequest:playableEventsRequest error:&error];
            if (playableEvents != nil) {
                NSEnumerator *eventsEnumerator = [playableEvents objectEnumerator];
                
                NSLog(@"got %d playable events for track '%@'", [playableEvents count], [aTrack name]);
                
                NSManagedObject* anEvent;
                
                while(anEvent = [eventsEnumerator nextObject]) {
                    // NSLog(@"event : %@ ", anEvent);
                    MIDINoteMessage msg;
                    msg.channel = [[aTrack channel] intValue];
                    msg.duration = [[anEvent duration] floatValue];
                    msg.velocity = [[anEvent velocity] intValue];
                    msg.note = [[anEvent note] intValue];
                    MusicTimeStamp timeStamp = [[anEvent absoluteTime] floatValue];
                    MusicTrackNewMIDINoteEvent(sequenceTrack, timeStamp, &msg);
                }
            } else {
                NSLog(@"error when fetching events for track");
            }
        }
        
    } else {
        NSLog(@"error when fetching track");
    }
    
    NSLog(@"CAShow sequence :");
    CAShow(sequence);
}

- (void)play {
    NSLog(@"Player:play");
    MusicPlayerSetTime(player, 0); // TODO 
    MusicPlayerPreroll(player);
    [self setLastError:MusicPlayerStart(player)];
}

- (void)stop {
    NSLog(@"Player:stop");
    [self setLastError:MusicPlayerStop(player)];
}

- (void)rewind {
    [self setLastError:MusicPlayerSetTime(player, 0)];
}

- (BOOL)isPlaying {
    Boolean res;
    [self setLastError:MusicPlayerIsPlaying(player, &res)];
    return res;
}


//////////// C Core Audio stuff

OSStatus SetUpGraph (AUGraph inGraph, UInt32 numFrames, Float64 sampleRate, bool isOffline)
{
	OSStatus result = noErr;
	AudioUnit outputUnit = 0;
	AUNode outputNode;
	
	// the frame size is the I/O size to the device
	// the device is going to run at a sample rate it is set at
	// so, when we set this, we also have to set the max frames for the graph nodes
	UInt32 nodeCount;
	require_noerr (result = AUGraphGetNodeCount (inGraph, &nodeCount), home);
    
	for (int i = 0; i < (int)nodeCount; ++i) 
	{
		AUNode node;
		require_noerr (result = AUGraphGetIndNode(inGraph, i, &node), home);
        
		ComponentDescription desc;
		AudioUnit unit;
		require_noerr (result = AUGraphNodeInfo(inGraph, node, &desc, &unit), home);
		
		if (desc.componentType == kAudioUnitType_Output) 
		{
			if (outputUnit == 0) {
				outputUnit = unit;
				require_noerr (result = AUGraphNodeInfo(inGraph, node, 0, &outputUnit), home);
				
				if (!isOffline) {
					// these two properties are only applicable if its a device we're playing too
					require_noerr (result = AudioUnitSetProperty (outputUnit, 
                                                                  kAudioDevicePropertyBufferFrameSize, 
                                                                  kAudioUnitScope_Output, 0,
                                                                  &numFrames, sizeof(numFrames)), home);
                    
                    //					require_noerr (result = AudioUnitAddPropertyListener (outputUnit, 
                    //                                                                          kAudioDeviceProcessorOverload, 
                    //                                                                          OverloadListenerProc, 0), home);
                    
					// if we're rendering to the device, then we render at its sample rate
					UInt32 theSize;
					theSize = sizeof(sampleRate);
					
					require_noerr (result = AudioUnitGetProperty (outputUnit,
                                                                  kAudioUnitProperty_SampleRate,
                                                                  kAudioUnitScope_Output, 0,
                                                                  &sampleRate, &theSize), home);
				} else {
                    // remove device output node and add generic output
					require_noerr (result = AUGraphRemoveNode (inGraph, node), home);
					desc.componentSubType = kAudioUnitSubType_GenericOutput;
					require_noerr (result = AUGraphAddNode (inGraph, &desc, &node), home);
					require_noerr (result = AUGraphNodeInfo(inGraph, node, NULL, &unit), home);
					outputUnit = unit;
					outputNode = node;
					
					// we render the output offline at the desired sample rate
					require_noerr (result = AudioUnitSetProperty (outputUnit,
                                                                  kAudioUnitProperty_SampleRate,
                                                                  kAudioUnitScope_Output, 0,
                                                                  &sampleRate, sizeof(sampleRate)), home);
				}
				// ok, lets start the loop again now and do it all...
				i = -1;
			}
		}
		else
		{
            // we only have to do this on the output side
            // as the graph's connection mgmt will propogate this down.
			if (outputUnit) {	
                // reconnect up to the output unit if we're offline
				if (isOffline && desc.componentType != kAudioUnitType_MusicDevice) {
					require_noerr (result = AUGraphConnectNodeInput (inGraph, node, 0, outputNode, 0), home);
				}
				
				require_noerr (result = AudioUnitSetProperty (unit,
                                                              kAudioUnitProperty_SampleRate,
                                                              kAudioUnitScope_Output, 0,
                                                              &sampleRate, sizeof(sampleRate)), home);
                
                
			}
		}
		require_noerr (result = AudioUnitSetProperty (unit, kAudioUnitProperty_MaximumFramesPerSlice,
                                                      kAudioUnitScope_Global, 0,
                                                      &numFrames, sizeof(numFrames)), home);
	}
	
home:
	return result;
}

OSStatus GetSynthFromGraph (AUGraph inGraph, AudioUnit outSynth)
{	
	UInt32 nodeCount;
	OSStatus result = noErr;
	require_noerr (result = AUGraphGetNodeCount (inGraph, &nodeCount), fail);
	
	for (UInt32 i = 0; i < nodeCount; ++i) 
	{
		AUNode node;
		require_noerr (result = AUGraphGetIndNode(inGraph, i, &node), fail);
        
		ComponentDescription desc;
		require_noerr (result = AUGraphNodeInfo(inGraph, node, &desc, 0), fail);
		
		if (desc.componentType == kAudioUnitType_MusicDevice) 
		{
			require_noerr (result = AUGraphNodeInfo(inGraph, node, 0, &outSynth), fail);
			return noErr;
		}
	}
	
fail:		// didn't find the synth AU
	return -1;
}




@end
