//
//  MyDocument.m
//  orchard
//
//  Created by Guillaume Laurent on 4/13/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "MyDocument.h"
#import "PlaybackCursorView.h"

@implementation MyDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
        // initialization code
    }
    return self;
}

- (NSString *)windowNibName 
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];

    // synchronize track list and track canvas scroll views
    [trackListView setSynchronizedScrollView:trackCanvasView];
}



- (IBAction)showPlayBackCursor:(id)sender
{
    NSLog(@"showPlayBackCursor : %d", [sender state]);

    
    [playbackCursorView setHidden:([sender state] == NSOffState)];
        
}


@end
