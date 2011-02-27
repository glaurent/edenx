//
//  Track.m
//  edenx
//
//  Created by Guillaume Laurent on 2/24/11.
//  Copyright 2011 telegraph-road.org. All rights reserved.
//

#import "Track.h"
#import "MyDocument.h"
#import "TracksController.h"

@implementation Track

- (void)awakeFromInsert
{
    [super awakeFromInsert];
 
    MyDocument* currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
    TracksController* tracksController = [currentDocument tracksController];

    uint count = [[tracksController content] count];
    
    NSLog(@"Track:awakeFromInsert : set index to = %d", count);
    [self setIndex:[NSNumber numberWithUnsignedInt:count]];
}

@end
