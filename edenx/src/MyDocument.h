//
//  MyDocument.h
//  orchard
//
//  Created by Guillaume Laurent on 4/13/08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SynchroScrollView.h"

@interface MyDocument : NSPersistentDocument {
    IBOutlet NSView* playbackCursorView;
    IBOutlet SynchroScrollView* trackListView;
    IBOutlet NSScrollView* trackCanvasView;
}

- (IBAction)showPlayBackCursor:(id)sender;
- (IBAction)editSelectedTrack:(id)sender;


@end
