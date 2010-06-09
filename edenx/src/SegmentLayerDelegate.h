//
//  SegmentLayerDelegate.h
//  edenx
//
//  Created by Guillaume Laurent on 6/6/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SegmentLayerDelegate : NSObject {

}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;

@end
