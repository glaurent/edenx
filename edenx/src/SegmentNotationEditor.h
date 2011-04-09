//
//  SegmentNotationEditor.h
//  edenx
//
//  Created by Guillaume Laurent on 4/4/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MyDocument;
@class NotationView;

@interface SegmentNotationEditor : NSWindowController {
@private
    MyDocument* editedDocument;

    IBOutlet NotationView* notationView;
}

@property (readonly) MyDocument* editedDocument;

@end
