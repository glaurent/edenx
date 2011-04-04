//
//  TrackEditor.h
//  edenx
//
//  Created by Guillaume Laurent on 3/21/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MyDocument;

// Editor window for single track (currently only an event list)

@interface SegmentEditor : NSWindowController {
    MyDocument* editedDocument;
    IBOutlet NSTableView* trackList;
}

- (id)initWithCurrentDocument:(MyDocument*)doc;

@property (readonly) MyDocument* editedDocument;

@end
