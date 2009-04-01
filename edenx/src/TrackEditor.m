//
//  TrackEditor.m
//  edenx
//
//  Created by Guillaume Laurent on 3/21/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "TrackEditor.h"


@implementation TrackEditor

- (id)init {
    if (![super initWithWindowNibName:@"TrackEditor"]) {
        return nil;
    }
    
    return self;
}

- (void)windowDidLoad
{
    NSLog(@"TrackEditor nib file is loaded");
}

@end
