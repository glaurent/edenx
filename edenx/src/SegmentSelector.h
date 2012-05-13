//
//  SegmentSelector.h
//  edenx
//
//  Created by Guillaume Laurent on 6/13/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SegmentSelector : NSObject {
    
    CGColorRef selectedOnShadowColor;
    
}

- (id)init;
- (void)setSelected:(CALayer*)segment toState:(BOOL)state;

@property (weak, nonatomic) CALayer* currentSelectedSegment;
@property (weak, nonatomic) CALayer* currentHoveredSegment;
@property (strong, readwrite) NSArrayController* segmentArrayController;

@end
