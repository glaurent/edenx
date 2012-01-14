//
//  NoteGlyphPathFactory.h
//  edenx
//
//  Created by Guillaume Laurent on 4/2/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NoteGlyphPathFactory : NSObject {
@private

    CTFontRef lilypondFontRef;
    
    CGAffineTransform glyphTransform;
    
    CGPathRef quadrupleRestPathRef;
    CGPathRef doubleRestPathRef;
    CGPathRef wholeRestPathRef;
    CGPathRef halfRestPathRef;
    CGPathRef quarterRestPathRef;
    CGPathRef eigthRestPathRef;
    CGPathRef sixteenthRestPathRef;
    CGPathRef thirtySecondthRestPathRef;
    CGPathRef sixtyFourthRestPathRef;
    
    CGPathRef wholeNotePathRef;
    CGPathRef halfNotePathRef;
    CGPathRef quarterNotePathRef;
    CGPathRef eigthNotePathRef;
    CGPathRef sixteenthNotePathRef;
    CGPathRef thirtySecondthNotePathRef;
    CGPathRef sixtyFourthNotePathRef;
    
}

-(id)initWithFont:(CTFontRef)fontRef withGlyphTransform:(CGAffineTransform)glyphTransform;

- (CGPathRef)pathForDuration:(uint)noteDuration isRest:(BOOL)isRest;

-(void)makeUpStemPaths;
-(void)makeRestPaths;

@property (readwrite) CTFontRef lilypondFontRef;
@property (readwrite) CGAffineTransform glyphTransform;

@property (readonly) CGPathRef quadrupleRestPathRef;
@property (readonly) CGPathRef doubleRestPathRef;
@property (readonly) CGPathRef wholeRestPathRef;
@property (readonly) CGPathRef halfRestPathRef;
@property (readonly) CGPathRef quarterRestPathRef;
@property (readonly) CGPathRef eigthRestPathRef;
@property (readonly) CGPathRef sixteenthRestPathRef;
@property (readonly) CGPathRef thirtySecondthRestPathRef;
@property (readonly) CGPathRef sixtyFourthRestPathRef;

@property (readonly) CGPathRef wholeNotePathRef;
@property (readonly) CGPathRef halfNotePathRef;
@property (readonly) CGPathRef quarterNotePathRef;
@property (readonly) CGPathRef eigthNotePathRef;
@property (readonly) CGPathRef sixteenthNotePathRef;
@property (readonly) CGPathRef thirtySecondthNotePathRef;
@property (readonly) CGPathRef sixtyFourthNotePathRef; 

@end
