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

    __strong CTFontRef lilypondFontRef;
    
    CGAffineTransform glyphTransform;
    
    __strong CGPathRef quadrupleRestPathRef;
    __strong CGPathRef doubleRestPathRef;
    __strong CGPathRef wholeRestPathRef;
    __strong CGPathRef halfRestPathRef;
    __strong CGPathRef quarterRestPathRef;
    __strong CGPathRef eigthRestPathRef;
    __strong CGPathRef sixteenthRestPathRef;
    __strong CGPathRef thirtySecondthRestPathRef;
    __strong CGPathRef sixtyFourthRestPathRef;
    
    __strong CGPathRef wholeNotePathRef;
    __strong CGPathRef halfNotePathRef;
    __strong CGPathRef quarterNotePathRef;
    __strong CGPathRef eigthNotePathRef;
    __strong CGPathRef sixteenthNotePathRef;
    __strong CGPathRef thirtySecondthNotePathRef;
    __strong CGPathRef sixtyFourthNotePathRef;
    
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
