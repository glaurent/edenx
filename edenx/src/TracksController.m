//
//  TracksController.m
//  edenx
//
//  Created by Guillaume Laurent on 9/20/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "TracksController.h"
#import "CoreDataStuff.h"

@implementation TracksController

- (NSArray*)recordingTracks
{    
    NSLog(@"TracksController recordingTracks");

    if (!inputSourceSetPredicate)
        inputSourceSetPredicate = [NSPredicate predicateWithFormat:@"(recording == YES) AND (inputSource != nil)"];

    [self setFilterPredicate:inputSourceSetPredicate];

    NSArray* res = [NSArray arrayWithArray:[self arrangedObjects]];
    
    [self setFilterPredicate:nil];
    
    return res;
}


@end
