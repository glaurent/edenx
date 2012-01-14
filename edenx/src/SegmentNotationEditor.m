//
//  SegmentNotationEditor.m
//  edenx
//
//  Created by Guillaume Laurent on 4/4/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import "SegmentNotationEditor.h"
#import "NotationView.h"

@implementation SegmentNotationEditor

@synthesize editedDocument;

- (id)initWithCurrentDocument:(MyDocument*)doc {
    if (![super initWithWindowNibName:@"NotationEditor"]) {
        return nil;
    }
    
    editedDocument = doc;
    
    NSString* fontDirPath = [[NSBundle mainBundle] pathForResource:@"GNU-LilyPond-feta-20" ofType:@"ttf"];

    NSURL* url = [NSURL fileURLWithPath:fontDirPath];
    
    CFErrorRef err;
    
    BOOL res = CTFontManagerRegisterFontsForURL((__bridge CFURLRef)url, kCTFontManagerScopeProcess, &err);

    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [notationView setFontLoaded];
}

@end
