//
//  NoteViewLayerDelegate.h
//  edenx
//
//  Created by Guillaume Laurent on 3/15/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NoteGlyphPathFactory;

@interface NoteViewLayerDelegate : NSObject {

    __strong CGColorRef drawColor;
    __strong CGColorRef bgColor;
    
    __strong CTFontRef lilypondFontRef;
    
    CGAffineTransform glyphTransform;
    
    NoteGlyphPathFactory* glyphPathFactory;
}

-(id)initWithFont:(CTFontRef)fontRef withGlyphTransform:(CGAffineTransform)glyphTransform;

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;

-(void)drawLayerNote:(CALayer *)layer inContext:(CGContextRef)context;

-(void)drawLayerNoteTest:(CALayer *)layer inContext:(CGContextRef)context;
-(void)drawLayerLine:(CALayer *)layer inContext:(CGContextRef)context;

@property (readwrite) CTFontRef lilypondFontRef;
@property (readwrite) CGAffineTransform glyphTransform;

@end
