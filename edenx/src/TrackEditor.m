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

//- (id)document
//{
//    id res = [super document];
//    NSLog(@"TrackEditor:document - returning %@", res);
//    
//    return res;
//}

- (id) editedDocument
{
    id res = [[NSDocumentController sharedDocumentController] currentDocument];

//    NSLog(@"TrackEditor:editedDocument - returning %@", res);
    
    return res;    
}

@end
