//
//  CALayerDebug.m
//  edenx
//
//  Created by Guillaume Laurent on 2/19/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import "CALayerDebug.h"


@implementation CALayerDebug

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setAnchorPoint:(CGPoint)point
{
    NSLog(@"CALayerDebug : %@ setting anchor point to %f,%f", [self name], point.x, point.y);
    [super setAnchorPoint:point];
}

- (void)setBounds:(CGRect)bounds
{
    NSLog(@"CALayerDebug : %@ setting bounds to %f,%f w=%f, h=%f", [self name], bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    [super setBounds:bounds];
}

- (void)setPosition:(CGPoint)point
{
    NSLog(@"CALayerDebug : %@ setting position from %f,%f to %f,%f x delta : %f", [self name], self.position.x, self.position.y, point.x, point.y, point.x - self.position.x);
    [super setPosition:point];    
}

@end
