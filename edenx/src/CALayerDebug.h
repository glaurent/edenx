//
//  CALayerDebug.h
//  edenx
//
//  Created by Guillaume Laurent on 2/19/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CALayerDebug : CALayer {
@private
    
}

- (void)setAnchorPoint:(CGPoint)point;
- (void)setBounds:(CGRect)bounds;
- (void)setPosition:(CGPoint)point;

@end
