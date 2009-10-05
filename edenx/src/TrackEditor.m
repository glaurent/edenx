//
//  TrackEditor.m
//  edenx
//
//  Created by Guillaume Laurent on 3/21/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "TrackEditor.h"
#import "MyDocument.h"
#import "TracksController.h"

@implementation TrackEditor

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
}

@synthesize editedDocument;

@end
