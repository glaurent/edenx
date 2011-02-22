//
//  SegmentSelector.m
//  edenx
//
//  Created by Guillaume Laurent on 6/13/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//

#import "SegmentSelector.h"


@implementation SegmentSelector

- (id)init
{
    self = [super init];
    
    currentSelectedSegment = nil;
    selectedOnShadowColor = CGColorCreateGenericRGB(0.8, 0.3, 0.3, 0.5); // red 
    CFMakeCollectable(selectedOnShadowColor);
    
    return self;
}

- (void)setCurrentSelectedSegment:(CALayer*)segmentRectangle
{
    // NSLog(@"SegmentSelector:setCurrentSelectedSegment %@", segment);
    
    if (currentSelectedSegment == segmentRectangle) {
        NSLog(@"segment already selected - nothing to do");
        return;
    }
    
    if (currentSelectedSegment != nil) {
        [self setSelected:currentSelectedSegment toState:NO];
        [currentSelectedSegment setNeedsDisplay];
    }
    
    currentSelectedSegment = segmentRectangle;
    if (currentSelectedSegment != nil) {
        id segment = [segmentRectangle valueForKey:@"segment"];
        uint segmentIdx = [[segmentArrayController arrangedObjects] indexOfObject:segment];
        
        NSLog(@"SegmentSelector:setCurrentSelectedSegment : idx = %d - # of objects : %d",
              segmentIdx,
              [[segmentArrayController arrangedObjects] count]);
        [segmentArrayController setSelectionIndex:segmentIdx];
        [self setSelected:currentSelectedSegment toState:YES];
        [currentSelectedSegment setNeedsDisplay];    
    }
}

- (CALayer*)currentSelectedSegment
{
    return currentSelectedSegment;
}

- (void)setSelected:(CALayer*)segment toState:(BOOL)state
{
    // NSLog(@"SegmentSelector:setSelected %@ to %d", segment, state);
    
    if (state == NO) {
        segment.shadowRadius = 0.0;
        segment.shadowColor = 0;
        segment.shadowOpacity = 0.0;
    } else {
        segment.shadowRadius = 3.0;
        segment.shadowColor = selectedOnShadowColor;
        segment.shadowOpacity = 1.0;
    }
}

@synthesize segmentArrayController;

@end
