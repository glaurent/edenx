//
//  NotationView.m
//  edenx
//
//  Created by Guillaume Laurent on 4/6/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NotationView.h"
#import "StaffLayerDelegate.h"

@implementation NotationView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        drawColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0); // solid black 
        debugColor = CGColorCreateGenericRGB(1.0, 0.5, 0.0, 0.5); // red
        debugColor2 = CGColorCreateGenericRGB(1.0, 0.0, 0.5, 0.5); // purple
        
//        glyphTransform = CGAffineTransformMakeScale(1.0, 1.0);
//        glyphTransform = CGAffineTransformTranslate(glyphTransform, 20.0, 20.0);

    }
    
    return self;
}

- (void)setFontLoaded
{
    NSLog(@"MyClass.setFontLoaded");
    
    lilyPondFontDescRef = CTFontDescriptorCreateWithNameAndSize(CFSTR("LilyPond-feta"), 0.0);
    lilyPondFontRef = CTFontCreateWithFontDescriptor(lilyPondFontDescRef, 20.0, NULL);
    
    NSLog(@"glyph count : %ld", CTFontGetGlyphCount(lilyPondFontRef));
    
    notationLayer = [CALayer layer];
    notationLayer.name = @"notationLayer";
    
    
// don't do that : scales bitmap-wise, horrible result
//
//    CATransform3D layerTransform = CATransform3DMakeScale(5.0, 5.0, 0.0);
//    
//    self.layer.transform = layerTransform;
    
    
    self.layer.layoutManager = [CAConstraintLayoutManager layoutManager];
    
//    notationLayer.bounds = CGRectMake(0.0, 0.0, 200.0, 200.0);
    
    notationLayer.autoresizingMask = kCALayerWidthSizable | kCALayerMinXMargin | kCALayerMaxXMargin;

    [notationLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX 
                                                            relativeTo:@"superlayer"
                                                             attribute:kCAConstraintMidX]];
    [notationLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY
                                                            relativeTo:@"superlayer"
                                                             attribute:kCAConstraintMidY]];
    [notationLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight 
                                                            relativeTo:@"superlayer"
                                                             attribute:kCAConstraintHeight
                                                                offset:5.0]];
    [notationLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth
                                                            relativeTo:@"superlayer"
                                                             attribute:kCAConstraintWidth
                                                                offset:5.0]];
    
    notationLayer.borderColor = debugColor;
    notationLayer.borderWidth = 1.0;
    
    [self.layer addSublayer:notationLayer];
    
    notationLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
    
    // staff layer
    staffLayer = [CALayer layer];
    staffLayer.name = @"staffLayer";
    
    staffLayer.borderColor = debugColor;
    staffLayer.borderWidth = 2.0;
    
    // get size of crotchet body glyph to dimension the stafflayer with
    //
    CGPathRef crotchetBodyPath = CTFontCreatePathForGlyph(lilyPondFontRef, 36, NULL);
    
    CGRect crotchetBoundingRect = CGPathGetBoundingBox(crotchetBodyPath);
    
    NSLog(@"crotchetBoundingRect origin : %f,%f", crotchetBoundingRect.origin.x, crotchetBoundingRect.origin.y);
    
    interlineSpace = crotchetBoundingRect.size.height;
    
    staffLayer.bounds = CGRectMake(0.0, 0.0, notationLayer.bounds.size.width,
                                   crotchetBoundingRect.size.height * 15);
    
    staffLayer.autoresizingMask = kCALayerWidthSizable | kCALayerMinXMargin | kCALayerMaxXMargin;
    
    StaffLayerDelegate* staffViewLayerDelegate = [[StaffLayerDelegate alloc] initWithInterlineSpace:interlineSpace];
    
    staffLayer.delegate = staffViewLayerDelegate;
    
    // center staff in notationLayer
    //
    [staffLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX 
                                                         relativeTo:@"superlayer"
                                                          attribute:kCAConstraintMidX]];
    [staffLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY
                                                         relativeTo:@"superlayer"
                                                          attribute:kCAConstraintMidY]];
    [staffLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth
                                                         relativeTo:@"superlayer"
                                                          attribute:kCAConstraintWidth]];
    
    [notationLayer addSublayer:staffLayer];
    [notationLayer setNeedsLayout];
    
    [self.layer setNeedsLayout];
    [self.layer setNeedsDisplay];
//    [notationLayer setNeedsDisplay];
    [staffLayer setNeedsDisplay];
    
    NSLog(@"NoteLayer bounds : %f,%f w=%f h=%f", notationLayer.bounds.origin.x, notationLayer.bounds.origin.y,
          notationLayer.bounds.size.width, notationLayer.bounds.size.height);
    NSLog(@"Main Layer bounds : %f,%f w=%f h=%f", self.layer.bounds.origin.x, self.layer.bounds.origin.y,
          self.layer.bounds.size.width, self.layer.bounds.size.height);
    
    
}

@end
