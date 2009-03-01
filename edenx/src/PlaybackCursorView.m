//
//  PlaybackCursorView.m
//  edenx
//
//  Created by Guillaume Laurent on 2/15/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "PlaybackCursorView.h"


@implementation PlaybackCursorView

- (id)initWithFrame:(NSRect)frame {
    NSLog(@"PlaybackCursorView:initWithFrame");
    
    self = [super initWithFrame:frame];
    if (self) {
        fillColor=[[NSColor blueColor] colorWithAlphaComponent:0.5];
        [fillColor retain];
        NSLog(@"fillColor = %x - self = %@", fillColor, self);
    } else {
        NSLog(@"PlayBackCursorView:initWithFrame - super init returned 0");
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    NSLog(@"in drawRect : fillColor = %x - self = %x", fillColor, self);
    [fillColor set];

    NSRectFill(rect);
}

- (void)setColor:(NSColor *)color
{
    NSLog(@"PlaybackCursorView:setColor");
//    [color retain];
//    [fillColor release];
//    fillColor=color;
}


@end
