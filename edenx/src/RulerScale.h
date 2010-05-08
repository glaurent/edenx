//
//  RulerScale.h
//  edenx
//
//  Created by Guillaume Laurent on 3/14/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//  Copyright 2000-2009 the Rosegarden development team.
//

#import <Cocoa/Cocoa.h>
#import <CoreDataStuff.h>

@class CompositionController;

@interface RulerScale : NSObject {
    CompositionController* compositionController;
    double origin;
    double ratio;
}

- (id)initWithCompositionController:(CompositionController*)c withOrigin:(double)o withRatio:(double)r;
- (int)firstVisibleBar;
- (int)lastVisibleBar;
- (double)barPosition:(int)barNumber;
- (double)barWidth:(int)barNumber;
- (double)beatWidth:(int)beatNumber;
- (int)barForX:(double)x;
- (timeT)timeForX:(double)x;
- (double)xForTime:(timeT)time;
- (timeT)durationForWidth:(double)x withWidth:(double)width;
- (double)widthForDuration:(timeT)startTime withDuration:(timeT)duration;

@end
