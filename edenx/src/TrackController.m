//
//  TrackController.m
//  edenx
//
//  Created by Guillaume Laurent on 3/21/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "TrackController.h"


@implementation TrackController

- (id)content
{
    id res = [super content];
    NSLog(@"TrackController - returning content %@", res);
    
    return res;
}

@end
