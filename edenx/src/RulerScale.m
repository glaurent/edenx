//
//  RulerScale.m
//  edenx
//
//  Created by Guillaume Laurent on 3/14/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//  Copyright 2000-2009 the Rosegarden development team.
//

#import "RulerScale.h"
#import "CompositionController.h"
#import "TimeSignatureController.h"

@implementation RulerScale

- (id)initWithCompositionController:(CompositionController*)c withOrigin:(double)o withRatio:(double)r
{
    self = [super init];
    if (self != nil) {
        compositionController = c;
        origin = o;
        ratio = r;
    }
    
    return self;
}

- (int)firstVisibleBar
{
    return [compositionController barNumber:[[[compositionController content] startMarker] intValue]];
}

- (int)lastVisibleBar
{
    return [compositionController barNumber:[[[compositionController content] endMarker] intValue]];    
}

- (double)barPosition:(int)barNumber
{
    timeT t = [compositionController barRange:barNumber].start;
    return [self xForTime:t];
}

- (double)barWidth:(int)barNumber
{
    return [self barPosition:(barNumber + 1)] - [self barPosition:barNumber];
}

- (double)beatWidth:(int)beatNumber
{
    BOOL isNew = NO;
    NSManagedObject<TimeSignature>* timeSig = [compositionController timeSignatureInBar:beatNumber isNew:&isNew];
    TimeSignatureController* timeSigController = [[TimeSignatureController alloc] initWithTimeSignature:timeSig];
    return [timeSigController beatDuration] / ratio;     
}

- (int)barForX:(double)x
{
    return [compositionController barNumber:[self timeForX:x]];
}

- (timeT)timeForX:(double)x
{
    timeT t = nearbyint((x - origin) * ratio);
    
    int firstBar = [self firstVisibleBar];
    if (firstBar != 0) {
        t += [compositionController barRange:firstBar].start;
    }
    
    return t;
}

- (double)xForTime:(timeT)t
{
    int firstBar = [self firstVisibleBar];
    if (firstBar != 0) {
        t -= [compositionController barRange:firstBar].start;
    }
    
    return origin + (double)t / ratio;
}

- (timeT)durationForWidth:(double)x withWidth:(double)width
{
    return [self timeForX:(x + width)] - [self timeForX:x];
}

- (double)widthForDuration:(timeT)startTime withDuration:(timeT)duration
{
    return [self xForTime:(startTime + duration)] - [self xForTime:startTime];
}


@end
