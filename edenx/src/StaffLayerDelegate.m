//
//  StaffViewLayerDelegate.m
//  edenx
//
//  Created by Guillaume Laurent on 3/28/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import "StaffLayerDelegate.h"


@implementation StaffLayerDelegate

- (id)initWithInterlineSpace:(float)space
{
    NSLog(@"StaffLayerDelegate:initWithInterlineSpace %f", space);
    
    self = [super init];
    if (self) {
        [self setInterlineSpace:space];
        drawColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0); // solid black
        CFMakeCollectable(drawColor);
    }
    
    return self;
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    NSLog(@"StaffViewLayerDelegate:drawLayer %f,%f - w=%f h=%f - position : %f,%f",
          layer.bounds.origin.x, layer.bounds.origin.y,
          layer.bounds.size.width, layer.bounds.size.height,
          layer.position.x, layer.position.y);
    
    CGRect contextBoundingRect = CGContextGetClipBoundingBox(context);
    
    CGMutablePathRef globalPath = CGPathCreateMutable();
    CFMakeCollectable(globalPath);
    
    float base = contextBoundingRect.size.height / 2 - (interlineSpace * 2.5);
    
    for(int i = 0; i < 5; ++i) {
        CGMutablePathRef linePath = CGPathCreateMutable();
        CFMakeCollectable(linePath);
        float height = base + (interlineSpace * i);
        CGPathMoveToPoint(linePath, NULL, 10.0, height);
        CGPathAddLineToPoint(linePath, NULL, contextBoundingRect.size.width - 5.0, height);
        CGPathCloseSubpath(linePath);
        CGPathAddPath(globalPath, NULL, linePath);
    }
        
    CGContextSetLineWidth(context, 0.5);
    
    CGContextSetFillColorWithColor(context, drawColor);
    CGContextAddPath(context, globalPath);
    
    CGContextDrawPath(context, kCGPathStroke);
    
}

@synthesize interlineSpace;

@end
