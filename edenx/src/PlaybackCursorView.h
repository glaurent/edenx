//
//  PlaybackCursorView.h
//  edenx
//
//  Created by Guillaume Laurent on 2/15/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PlaybackCursorView : NSView {
    NSColor *fillColor;
}

- (void)setColor:(NSColor *)color;


@end
