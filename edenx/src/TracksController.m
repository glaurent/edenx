//
//  TracksController.m
//  edenx
//
//  Created by Guillaume Laurent on 9/20/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "TracksController.h"
#import "PYMIDI.h"

#import "CoreDataStuff.h"

@implementation TracksController

- (id)initWithContent:(id)content
{
    NSLog(@"TracksController.initWithContent");
    
    self = [super initWithContent:content];

//    NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:NO];
//    
//    [self setSortDescriptors:[NSArray arrayWithObject:sd]];
//    [self rearrangeObjects];
//    
    return self;
}

- (id)init
{
    NSLog(@"TracksController.init");
    
    self = [super init];
    
//    NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:NO];
//    
//    [self setSortDescriptors:[NSArray arrayWithObject:sd]];
//    [self rearrangeObjects];
    
    return self;
}


- (NSArray*)recordingTracks
{    
    NSLog(@"TracksController recordingTracks");

    if (!inputSourceSetAndRecordingPredicate)
        inputSourceSetAndRecordingPredicate = [NSPredicate predicateWithFormat:@"(recording == YES) AND (inputSource != nil)"];

    [self setFilterPredicate:inputSourceSetAndRecordingPredicate];

    NSArray* res = [NSArray arrayWithArray:[self arrangedObjects]];
    
    [self setFilterPredicate:nil];
    
    return res;
}

- (NSArray*)inputSourceSetTracks
{    
    NSLog(@"TracksController recordingTracks");
    
    if (!inputSourceSetPredicate)
        inputSourceSetPredicate = [NSPredicate predicateWithFormat:@"inputSource != nil"];
    
    [self setFilterPredicate:inputSourceSetPredicate];
    
    NSArray* res = [NSArray arrayWithArray:[self arrangedObjects]];
    
    [self setFilterPredicate:nil];
    
    return res;
}

- (void)handleMIDIRemoveObject:(NSNotification*)notification
{
    NSLog(@"TracksController:handleMIDIRemoveObject");    
    id midiObject = [[notification userInfo] objectForKey:PYMIDIAddedRemovedObject];

    for(NSManagedObject<Track>* track in [self arrangedObjects]) {
//        NSLog(@"TracksController:handleMIDIRemoveObject : checking track %@", track);
        if ([track inputSource] == midiObject) {
//            NSLog(@"match - deselecting");
            [track setInputSource:nil];
        }
    }
}

@end
