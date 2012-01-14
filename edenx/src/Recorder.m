//
//  Recorder.m
//  edenx
//
//  Created by Guillaume Laurent on 9/12/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#include <CoreAudio/CoreAudio.h>

#import "Recorder.h"
#import "AppController.h"

#import "PYMIDI/PYMIDI.h"
#import "MIDIReceiver.h"
#import "SMMessage.h"

#import "TracksController.h"
#import "MyDocument.h"
#import "CoreDataStuff.h"

#import "MIDIReceiverTrackDelegate.h"

@interface Recorder (private)
{
    
}

- (NSManagedObject<Segment>*)getFirstSuitableRecordingSegmentInTrack:(NSManagedObject<Track>*)track;

@end

@implementation Recorder

- (id)init
{

    self = [ super init ];
    NSLog(@"Recorder init");
    if (self != nil) {
            
        midiSources = [NSMutableArray arrayWithCapacity:5];
        recordingStartTime = 0;
        
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
        disableSound = [args boolForKey:@"disableSound"];
        NSLog(@"Recorder init : disableSound = %d", disableSound);
    }

    return self;
}

- (void)setup
{
    [midiSourcesController setContent:midiSources];

    if (!disableSound) {
        
        // get MIDI sources
        //
        PYMIDIManager* manager = [PYMIDIManager sharedInstance];
        NSMutableArray* tmp = [NSMutableArray arrayWithCapacity:[[manager realSources] count]];
        
        NSLog(@"Recorder init : midiSourcesController = %@", midiSourcesController);
        [midiSourcesController addObjects:[manager realSources]];
        NSLog(@"Recorder init : nb of midi sources : %lu", [tmp count]);
        NSLog(@"Recorder init : nb of controller items : %lu", [[midiSourcesController arrangedObjects] count]);
        NSLog(@"Recorder init : nb of added midi sources : %lu", [midiSources count]);
        
        // notifs for MIDI environment changes
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMIDIAddObject:)    name:PYMIDIObjectAdded   object:manager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMIDIRemoveObject:) name:PYMIDIObjectRemoved object:manager];

    }
    
}

- (void)start
{
    NSLog(@"Recorder : start recording");
    
    recording = YES;
    recordingStartTime = AudioGetCurrentHostTime();
    
    MyDocument* currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
    TracksController* tracksController = [currentDocument tracksController];
    
    NSArray* recordingTracks = [tracksController recordingTracks];

    NSLog(@"Recorder.start : recordingTracks count = %lu", [recordingTracks count]);
    
    midiReceiversToEndPointsTable = [NSMapTable mapTableWithStrongToStrongObjects];
    
    for(NSManagedObject<Track>* track in recordingTracks) {
        PYMIDIEndpoint* ep = [track inputSource];
        NSLog(@"Recorder : recording from '%@' on track '%@'", [ep name], [track name]);
        
        NSLog(@"document MOC : %@ - track MOC : %@", [currentDocument managedObjectContext], [track managedObjectContext]);
        
        NSManagedObject<Segment>* segment = [self getFirstSuitableRecordingSegmentInTrack:track];
        
        // create midiReceiver and its delegate
        MIDIReceiver* midiReceiver = [[MIDIReceiver alloc] init];
        MIDIReceiverTrackDelegate* receiverTrackDelegate = [[MIDIReceiverTrackDelegate alloc] 
                                                            initWithTrack:segment 
                                                            withStartTime:recordingStartTime
                                                            withMusicSequence:[currentDocument sequence]];
        
        // setup midiReceiver so it gets messages from this endPoint, and forwards them to receiverTrackDelegate
        [midiReceiver setDelegate:receiverTrackDelegate];
        [ep addReceiver:midiReceiver];

        // keep association midiReceiver<->ep so we can remove the receiver from the endpoint when recording stops
        [midiReceiversToEndPointsTable setObject:midiReceiver forKey:ep];
    }
    

}

- (NSManagedObject<Segment>*)getFirstSuitableRecordingSegmentInTrack:(NSManagedObject<Track>*)track
{
    NSMutableSet* trackSegments = track.segments;

    long startTime = 0;
    NSManagedObject<Segment>* lastSegment = nil;
    
    // find last segment
    for(NSManagedObject<Segment>* segment in trackSegments) {
        if ([[segment startTime] longValue] > startTime) {
            lastSegment = segment;
        }
    }    

    if (!lastSegment) {
        // create one
        
        MyDocument* currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
        
        lastSegment = [currentDocument createSegmentInTrack:track startingAtTime:0 endingAtTime:100];
        
    } 

    return lastSegment;
}

- (void)stop
{
    NSLog(@"Recorder : stop recording");
    
    for (PYMIDIEndpoint* ep in [midiReceiversToEndPointsTable keyEnumerator] ) {
        [ep removeReceiver:[midiReceiversToEndPointsTable objectForKey:ep]];
    }
    
    recording = NO;
    recordingStartTime = 0;
}


- (void)handleMIDIAddObject:(NSNotification*)notification
{
    NSLog(@"Recorder handleMIDIAddObject");
    id midiObject = [[notification userInfo] objectForKey:PYMIDIAddedRemovedObject];
    [midiSourcesController addObject:midiObject];
}

- (void)handleMIDIRemoveObject:(NSNotification*)notification
{
    NSLog(@"Recorder handleMIDIRemoveObject");    
    id midiObject = [[notification userInfo] objectForKey:PYMIDIAddedRemovedObject];
    // iterate over all endpoints in midiSources, find the one which has just been removed
    for(id ep in midiSources) {
        if (ep == midiObject) {
            NSLog(@"Recorder : removing object");
            [midiSourcesController removeObject:ep];
            break;
        }
    }
}

@synthesize midiSources;
@synthesize midiSourcesController;
@synthesize recording;
@synthesize recordingStartTime;
@synthesize disableSound;

@end
