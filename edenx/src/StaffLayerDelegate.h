//
//  StaffViewLayerDelegate.h
//  edenx
//
//  Created by Guillaume Laurent on 3/28/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StaffLayerDelegate : NSObject {
@private
    
    __strong CGColorRef drawColor;

    float interlineSpace;
}

- (id)initWithInterlineSpace:(float)space;

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;

@property (readwrite) float interlineSpace;

@end
