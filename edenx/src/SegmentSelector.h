//
//  SegmentSelector.h
//  edenx
//
//  Created by Guillaume Laurent on 6/13/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SegmentSelector : NSObject {
    
    CALayer* currentSelectedSegment;
    
    __strong CGColorRef selectedOnShadowColor;
}

- (id)init;
- (void)setSelected:(CALayer*)segment toState:(BOOL)state;

@property (readwrite,assign) CALayer* currentSelectedSegment;

@end
