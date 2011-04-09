//
//  NotationView.h
//  edenx
//
//  Created by Guillaume Laurent on 4/6/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NotationView : NSView {
@private

    float interlineSpace;

    __strong CGColorRef drawColor;
    __strong CGColorRef debugColor;
    __strong CGColorRef debugColor2;

    __strong CTFontDescriptorRef lilyPondFontDescRef;
    __strong CTFontRef lilyPondFontRef;
    
//    CGAffineTransform glyphTransform;

    CALayer* notationLayer;
    CALayer* staffLayer;

}

- (void)setFontLoaded;

@end
