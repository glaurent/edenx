//
//  TrackEditor.m
//  edenx
//
//  Created by Guillaume Laurent on 3/21/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "SegmentEditor.h"
#import "MyDocument.h"
#import "TracksController.h"

@implementation SegmentEditor

- (id)initWithCurrentDocument:(MyDocument*)doc {
    if (![super initWithWindowNibName:@"TrackEditor"]) {
        return nil;
    }
    
    editedDocument = doc;
    
    return self;
}

- (void)windowDidLoad
{
    NSLog(@"TrackEditor nib file is loaded");
    
    NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"absoluteTime" ascending:YES];
    
    [trackList setSortDescriptors:[NSArray arrayWithObject:sd]];
    
}

@synthesize editedDocument;

@end
