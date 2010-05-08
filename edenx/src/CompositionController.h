//
//  CompositionController.h
//  edenx
//
//  Created by Guillaume Laurent on 3/1/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CoreDataStuff.h"

@class MyDocument;

typedef struct {
    timeT start;
    timeT end;
} timerange;

@interface CompositionController : NSObjectController {

    BOOL barPositionsNeedCalculating;
    NSManagedObject<TimeSignature> *dummyTimeSig; // used in find*InTimeSignatures
    MyDocument* document;
}

// override prepareContent to ensure a Composition is there
//
- (void)prepareContent;

// methods from Rosegarden::Composition
- (void)calculateBarPositions;
- (int) nbBars;
- (int) barNumber:(timeT)t;
- (timeT) barStart:(uint)n;
- (timeT) barEnd:(uint)n;
- (timeT) duration;
- (timerange) barRangeForTime:(timeT)t;
- (timerange) barRange:(uint)n;
- (NSUInteger) findNearestTimeInTimeSignatures:(timeT)t;
- (NSUInteger) findTimeInTimeSignatures:(timeT)t;
- (timeT) timeSignaturesDuration;
- (NSManagedObject<TimeSignature>*) timeSignatureInBar:(int)barNo isNew:(BOOL*)isnew;


@property (readonly) MyDocument* document;

@end
