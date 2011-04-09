//
//  NoteGlyphPathFactory.m
//  edenx
//
//  Created by Guillaume Laurent on 4/2/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import "NoteGlyphPathFactory.h"


@implementation NoteGlyphPathFactory

-(id)initWithFont:(CTFontRef)fontRef withGlyphTransform:(CGAffineTransform)transform
{
    self = [super init];
    
    if (self) {
        lilypondFontRef = fontRef;
        glyphTransform = transform;
        
        [self makeUpStemPaths];
        [self makeRestPaths];
    }
    
    return self;
}

- (CGPathRef)pathForDuration:(uint)noteDuration isRest:(BOOL)isRest
{
    // TODO
    return eigthNotePathRef;
}

// G clef : 111-112
// Bass : 109-110
// Ut clef : 107-108
// Tab: 115-116

// sharp : 25
// becarre : 26
// flat : 27
// double flat : 28

// semibreve : 5
// minim : 6
// long 8
// breve 9
// 4th - crotchet rest : 10
// 8th - quaver rest : 12
// 16th rest : 13
// 32nd rest : 14
// 64th rest : 15



- (void)makeRestPaths
{
    quadrupleRestPathRef      = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 9,  &glyphTransform));
    doubleRestPathRef         = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 8,  &glyphTransform));
    wholeRestPathRef          = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 5,  &glyphTransform));
    halfRestPathRef           = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 6,  &glyphTransform));
    quarterRestPathRef        = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 10,  &glyphTransform));
    eigthRestPathRef          = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 12,  &glyphTransform));
    sixteenthRestPathRef      = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 13,  &glyphTransform));
    thirtySecondthRestPathRef = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 14,  &glyphTransform));
    sixtyFourthRestPathRef    = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 15,  &glyphTransform));  

}

// whole-note body : 34
// crotchet / quarter (body) : 36
// upward crotchets : 95 - 98
// downward crotchets : 99, 102-104
// up stem : 105
// down stem : 106

- (void)makeUpStemPaths
{
    CGFloat fontDescent = CTFontGetDescent(lilypondFontRef);
    
    // up stem
    //
    CGPathRef stemPath = CTFontCreatePathForGlyph(lilypondFontRef, 105, &glyphTransform);
    CFMakeCollectable(stemPath);
    
    // whole note
    //
    wholeNotePathRef = CTFontCreatePathForGlyph(lilypondFontRef, 34,  &glyphTransform);
    CFMakeCollectable(wholeNotePathRef);
    
    // half note
    //
    CGMutablePathRef tmpPath = (CGMutablePathRef)CFMakeCollectable(CGPathCreateMutable());
    CGPathRef tmpBodyPath = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 35,  &glyphTransform)); 
    
    CGPathAddPath(tmpPath, NULL, tmpBodyPath);
    
    CGRect noteBodyBoundingRect = CGPathGetBoundingBox(tmpBodyPath);
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(noteBodyBoundingRect.size.width - 1.0, 0.0);
    
    CGPathAddPath(tmpPath, &translate, stemPath);
    
    halfNotePathRef = CFMakeCollectable(CGPathCreateCopy(tmpPath));
    
    // crotchet / quarter
    //
    tmpPath = CGPathCreateMutable();
    CFMakeCollectable(tmpPath);
    tmpBodyPath = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 36,  &glyphTransform)); 
    
    CGPathAddPath(tmpPath, NULL, tmpBodyPath);
    
    noteBodyBoundingRect = CGPathGetBoundingBox(tmpBodyPath);
    
    CGAffineTransform translateNoteBody = CGAffineTransformMakeTranslation(noteBodyBoundingRect.size.width - 1.0, 0.0);
    
    CGPathAddPath(tmpPath, &translateNoteBody, stemPath);
    
    quarterNotePathRef = CFMakeCollectable(CGPathCreateCopy(tmpPath));
    
    // 8th
    //
    tmpPath = CGPathCreateMutable();
    CFMakeCollectable(tmpPath);
    
    CGPathAddPath(tmpPath, NULL, tmpBodyPath);
    
    CGPathAddPath(tmpPath, &translateNoteBody, stemPath);
    
    CGPathRef crotchetPath = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 95,  &glyphTransform));
    
    CGRect stemBoundingRect = CGPathGetBoundingBox(stemPath);
    CGRect crotchetBoundingRect = CGPathGetBoundingBox(crotchetPath);
    
    CGAffineTransform translateNoteBodyAndStem = CGAffineTransformTranslate(translateNoteBody,
                                                                            stemBoundingRect.size.width - 0.0,
                                                                            stemBoundingRect.size.height + crotchetBoundingRect.size.height / 2 - fontDescent);
    
    CGPathAddPath(tmpPath, &translateNoteBodyAndStem, crotchetPath);
    
    eigthNotePathRef = CFMakeCollectable(CGPathCreateCopy(tmpPath));
    
    // 16th
    //
    tmpPath = CGPathCreateMutable();
    CFMakeCollectable(tmpPath);
    
    CGPathAddPath(tmpPath, NULL, tmpBodyPath);
    
    CGPathAddPath(tmpPath, &translateNoteBody, stemPath);
    
    crotchetPath = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 96,  &glyphTransform));
    
    crotchetBoundingRect = CGPathGetBoundingBox(crotchetPath);
    
    translateNoteBodyAndStem = CGAffineTransformTranslate(translateNoteBody,
                                                          stemBoundingRect.size.width - 0.0,
                                                          stemBoundingRect.size.height + crotchetBoundingRect.size.height / 2 - fontDescent);
    
    CGPathAddPath(tmpPath, &translateNoteBodyAndStem, crotchetPath);
    
    sixteenthNotePathRef = CFMakeCollectable(CGPathCreateCopy(tmpPath));
    
    // 32nd
    //
    tmpPath = CGPathCreateMutable();
    CFMakeCollectable(tmpPath);
    
    CGPathAddPath(tmpPath, NULL, tmpBodyPath);
    
    CGPathAddPath(tmpPath, &translateNoteBody, stemPath);
    
    crotchetPath = CFMakeCollectable(CTFontCreatePathForGlyph(lilypondFontRef, 97,  &glyphTransform));
    
    crotchetBoundingRect = CGPathGetBoundingBox(crotchetPath);
    
    translateNoteBodyAndStem = CGAffineTransformTranslate(translateNoteBody,
                                                          stemBoundingRect.size.width - 0.0,
                                                          stemBoundingRect.size.height + crotchetBoundingRect.size.height / 2 - fontDescent);
    
    CGPathAddPath(tmpPath, &translateNoteBodyAndStem, crotchetPath);
    
    thirtySecondthNotePathRef = CFMakeCollectable(CGPathCreateCopy(tmpPath));
    
    // 64th
    //
    tmpPath = CGPathCreateMutable();
    CFMakeCollectable(tmpPath);
    
    CGPathAddPath(tmpPath, NULL, tmpBodyPath);
    
    CGPathAddPath(tmpPath, &translateNoteBody, stemPath);
    
    crotchetPath = CTFontCreatePathForGlyph(lilypondFontRef, 98,  &glyphTransform);
    CFMakeCollectable(crotchetPath);
    
    crotchetBoundingRect = CGPathGetBoundingBox(crotchetPath);
    
    translateNoteBodyAndStem = CGAffineTransformTranslate(translateNoteBody,
                                                          stemBoundingRect.size.width - 0.0,
                                                          stemBoundingRect.size.height + crotchetBoundingRect.size.height / 2 - fontDescent);
    
    CGPathAddPath(tmpPath, &translateNoteBodyAndStem, crotchetPath);
    
    sixtyFourthNotePathRef = CFMakeCollectable(CGPathCreateCopy(tmpPath));
    
}



@synthesize lilypondFontRef;
@synthesize glyphTransform;

@synthesize quadrupleRestPathRef;
@synthesize doubleRestPathRef;
@synthesize wholeRestPathRef;
@synthesize halfRestPathRef;
@synthesize quarterRestPathRef;
@synthesize eigthRestPathRef;
@synthesize sixteenthRestPathRef;
@synthesize thirtySecondthRestPathRef;
@synthesize sixtyFourthRestPathRef;

@synthesize wholeNotePathRef;
@synthesize halfNotePathRef;
@synthesize quarterNotePathRef;
@synthesize eigthNotePathRef;
@synthesize sixteenthNotePathRef;
@synthesize thirtySecondthNotePathRef;
@synthesize sixtyFourthNotePathRef;


@end
