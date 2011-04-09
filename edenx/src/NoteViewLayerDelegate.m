//
//  NoteViewLayerDelegate.m
//  edenx
//
//  Created by Guillaume Laurent on 3/15/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import "NoteViewLayerDelegate.h"
#import "NoteGlyphPathFactory.h"

@implementation NoteViewLayerDelegate

-(id)initWithFont:(CTFontRef)fontRef withGlyphTransform:(CGAffineTransform)transform
{
    self = [super init];
    
    if (self) {
        lilypondFontRef = fontRef;
        glyphTransform = transform;
        drawColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0); // solid black 
        bgColor = CGColorCreateGenericRGB(1.0, 1.0, 0.0, 0.5); 
        CFMakeCollectable(drawColor);
        CFMakeCollectable(bgColor);
        
        glyphPathFactory = [[NoteGlyphPathFactory alloc] initWithFont:lilypondFontRef withGlyphTransform:transform];
        
    }
    
    return self;
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    NSLog(@"NoteViewLayerDelegate:drawLayer");
    
    [self drawLayerNote:layer inContext:context];
//    [self drawLayerNoteTest:layer inContext:context];
//    [self drawLayerLine:layer inContext:context];
}

-(void)drawLayerNote:(CALayer *)layer inContext:(CGContextRef)context
{
    NSLog(@"NoteViewLayerDelegate:drawLayerNote - layer name : %@", layer.name);
    NSLog(@"NoteViewLayerDelegate:drawLayerNote %f,%f - w=%f h=%f - position : %f,%f",
          layer.bounds.origin.x, layer.bounds.origin.y,
          layer.bounds.size.width, layer.bounds.size.height,
          layer.position.x, layer.position.y);

    const float scaleFactor = 1.0;
    
    CGContextScaleCTM(context, scaleFactor, scaleFactor);

    CGMutablePathRef globalPath = CGPathCreateMutable();
    CFMakeCollectable(globalPath);
    
    CGPathRef quarterNotePathRef = glyphPathFactory.quarterNotePathRef;
    CGRect pathBoundingRect = CGPathGetBoundingBox(quarterNotePathRef);
    
    // center in layer
    //
    CGAffineTransform center = CGAffineTransformMakeTranslation(layer.bounds.size.width / (2 * scaleFactor), layer.bounds.size.height / (2 * scaleFactor));

    center = CGAffineTransformTranslate(center, -pathBoundingRect.origin.x, -pathBoundingRect.origin.y);
    
    CGPathAddPath(globalPath, &center, glyphPathFactory.quarterNotePathRef);

//    CGPathMoveToPoint(globalPath, NULL, 0.0, 0.0);
//    CGPathAddPath(globalPath, NULL, quarterNotePathRef);

//    CGPathAddPath(globalPath, &center, eigthNotePathRef);
//    CGPathAddPath(globalPath, &center, thirtySecondthNotePathRef);
//    CGPathAddPath(globalPath, &center, sixtyFourthNotePathRef);

    CGContextSetLineWidth(context, 2.0);

    // debug
    CGContextSetFillColorWithColor(context, bgColor);
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));

    CGContextSetFillColorWithColor(context, drawColor);
    CGContextAddPath(context, globalPath);
    
    CGContextDrawPath(context, kCGPathFill);
}


//
// for test only - build a compound note glyph and draw it
//
-(void)drawLayerNoteTest:(CALayer *)layer inContext:(CGContextRef)context
{
    NSLog(@"drawLayerNoteTest");
    
    const float scaleFactor = 1.0;
    
    CGContextScaleCTM(context, scaleFactor, scaleFactor);
    
//    CGFloat fontAscent = CTFontGetAscent(lilypondFontRef);
    CGFloat fontDescent = CTFontGetDescent(lilypondFontRef);
    
    CGPathRef crotchetBodyPath = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 36,  &glyphTransform));
    CGPathRef stemPath         = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 105, &glyphTransform));
    CGPathRef crotchetPath     = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 98,  &glyphTransform));
    
    CGMutablePathRef globalPath = CGPathCreateMutable();
    CFMakeCollectable(globalPath);
    
    CGAffineTransform center = CGAffineTransformMakeTranslation(layer.bounds.size.width / (2 * scaleFactor), layer.bounds.size.height / (2 * scaleFactor));
    
    CGPathAddPath(globalPath, &center, crotchetBodyPath);
    
    CGRect crotchetBodyBoundingRect = CGPathGetBoundingBox(crotchetBodyPath);
    
    CGAffineTransform translate = CGAffineTransformTranslate(center,
                                                             crotchetBodyBoundingRect.size.width - 1.0, 0.0);
    
    CGPathAddPath(globalPath, &translate, stemPath);
    
    CGRect stemBoundingRect = CGPathGetBoundingBox(stemPath);
    CGRect crotchetBoundingRect = CGPathGetBoundingBox(crotchetPath);
    
//    NSLog(@"stemBoundingRect : %f", stemBoundingRect.size.height);
    
    translate = CGAffineTransformTranslate(translate, stemBoundingRect.size.width - 0.0, stemBoundingRect.size.height + crotchetBoundingRect.size.height / 2 - fontDescent);
    
    CGPathAddPath(globalPath, &translate, crotchetPath);
    
//    CGRect pathBoundingRect = CGPathGetBoundingBox(globalPath);
//    NSLog(@"path bounding rect : %f,%f w=%f h=%f", pathBoundingRect.origin.x, pathBoundingRect.origin.y,
//          pathBoundingRect.size.width, pathBoundingRect.size.height);
    
    CGContextSetLineWidth(context, 2.0);

    CGContextSetFillColorWithColor(context, drawColor);
    CGContextAddPath(context, globalPath);
    
    CGContextDrawPath(context, kCGPathFill);
    
}

//
// for test only - draw a diagonal line across the layer rect
//
-(void)drawLayerLine:(CALayer *)layer inContext:(CGContextRef)context
{
    NSLog(@"NoteView.drawLayer : %f,%f w=%f h=%f", layer.bounds.origin.x, layer.bounds.origin.y,
          layer.bounds.size.width, layer.bounds.size.height);

    CGRect contextBoundingRect = CGContextGetClipBoundingBox(context);
    
    NSLog(@"contextBoundingRect : %f,%f w=%f, h=%f", contextBoundingRect.origin.x, contextBoundingRect.origin.y,
          contextBoundingRect.size.width, contextBoundingRect.size.height);
    
//    const float scaleFactor = 1.0;
//    
//    CGContextScaleCTM(context, scaleFactor, scaleFactor);
    
    CGMutablePathRef globalPath = CGPathCreateMutable();
    CFMakeCollectable(globalPath);
    
    CGPathMoveToPoint(globalPath, NULL, 30.0, 30.0);

    CGPoint startPoint = CGPathGetCurrentPoint(globalPath);
    
    NSLog(@"startPoint : %f,%f", startPoint.x, startPoint.y);

    CGPathAddLineToPoint(globalPath, NULL, 150.0, 150.0);
//    CGPathAddLineToPoint(globalPath, NULL, 0.0, 50.0);
//    CGPathAddLineToPoint(globalPath, NULL, 50.0, 0.0);
//    CGPathCloseSubpath(globalPath);

    // test rect
    CGPathAddRect(globalPath, NULL, CGRectMake(20.0, 20.0, 10.0, 10.0));
    
    CGContextSetLineWidth(context, 2.0);

    CGContextSetFillColorWithColor(context, bgColor);
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));
    
    CGContextSetFillColorWithColor(context, drawColor);
    CGContextAddPath(context, globalPath);
//    CGContextEOFillPath(context);
    
    CGContextDrawPath(context, kCGPathStroke);
    
}

@synthesize lilypondFontRef;
@synthesize glyphTransform;

@end
