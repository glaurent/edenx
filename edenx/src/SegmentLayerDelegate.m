//
//  SegmentLayerDelegate.m
//  edenx
//
//  Created by Guillaume Laurent on 6/6/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//

#import "SegmentLayerDelegate.h"


@implementation SegmentLayerDelegate

- (id)init
{
    self = [super init];
    
    if (self) {
        handleFillColor = CGColorCreateGenericRGB(0.3, 0.5, 0.5, 0.8); // greenish 
        CFMakeCollectable(handleFillColor);

    }
    
    return self;
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    //    float segmentStart = [[layer valueForKey:@"segmentStart"] floatValue];
    //    float segmentWidth = [[layer valueForKey:@"segmentWidth"] floatValue];
    //    CGColorRef segmentFillColor = [[[layer superlayer] valueForKey:@"segmentFillColor"] pointerValue];
    //    
    //    NSLog(@"drawLayer : start %d - width %d", segmentStart, segmentWidth);
    //    
    //    // TODO - draw preview here
    //    
    //    CGRect segmentVisibleRect = CGRectMake(segmentStart, 0, segmentWidth, layer.bounds.size.height);
    //    
    //    CGMutablePathRef thePath = CGPathCreateMutable();
    //    
    //    CGPathAddRect(thePath, NULL, segmentVisibleRect);
    //    
    //    CGContextBeginPath(context);
    //    CGContextAddPath(context, thePath );
    //    
    //    CGContextSetLineWidth(context,
    //                          2.0);
    //    CGContextSetFillColorWithColor(context, segmentFillColor);
    //    CGContextDrawPath(context, kCGPathFill);
    //    
    //    // release the path
    //    CFRelease(thePath);
    
    NSNumber* hoveredNb = [layer valueForKey:@"hovered"];
    
    if (hoveredNb && [hoveredNb boolValue]) {
    
        CGMutablePathRef leftHandlePath = CGPathCreateMutable();
        CGPathAddArc(leftHandlePath, NULL, 0, layer.bounds.size.height / 2, handleRadius, -M_PI_2, M_PI_2, NO);
        
        CGMutablePathRef rightHandlePath = CGPathCreateMutable();
        CGPathAddArc(rightHandlePath, NULL, layer.bounds.size.width, layer.bounds.size.height / 2, handleRadius, M_PI_2, -M_PI_2, NO);
        
        CGContextAddPath(context, leftHandlePath);
        CGContextAddPath(context, rightHandlePath);
        
        CGContextSetLineWidth(context, 2.0);
        CGContextSetFillColorWithColor(context, handleFillColor);
        CGContextDrawPath(context, kCGPathFill);
        
        CFRelease(leftHandlePath);
        CFRelease(rightHandlePath);

    }
    
}

@end
