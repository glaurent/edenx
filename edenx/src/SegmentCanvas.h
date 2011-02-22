//
//  SegmentCanvas.h
//  edenx
//
//  Created by Guillaume Laurent on 6/6/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "CoreDataStuff.h"

@class SegmentSelector;

@interface SegmentCanvas : NSView {

    CALayer* containerLayerForRectangles;
    CGPoint mouseDownPoint;
    CGPoint previousMouseDownPoint;
    unsigned int rectHeight;
    id rectangleLayerDelegate;
    BOOL forgetSegmentTimeChanges;
    BOOL forgetSegmentAdd; // set to YES on initial segment creation in mouseUp
    
    __strong CGColorRef rectFillColor;
    __strong CGColorRef rectBorderColor;
    __strong CGColorRef rectHandleColor;
    __strong CGColorRef redColor;
    __strong CGColorRef blueColor;
    
    CALayer* hitLayer;
    CALayer* hitHandleLayer;
    CALayer* hitRectLayer;
    CALayer* hitStripLayer;
    float mouseDownXOffset;
    
    SegmentSelector* segmentSelector;

    NSArrayController* tracksController;

}

- (void)addStripLayerForTracks:(NSArray*)tracks;
- (CALayer*)addStripLayerForNewTrack:(NSManagedObject<Track>*)track;
- (CALayer*)addStripLayerForTrack:(NSManagedObject<Track>*)track atIndex:(uint)index;
- (id)addRectangleForSegment:(NSManagedObject<Segment>*)segment inTrack:(NSManagedObject<Track>*)associatedTrack;

@property (readonly) unsigned int rectHeight;
@property (readwrite, assign) CALayer* containerLayerForRectangles;
@property (readwrite, assign) CGPoint mouseDownPoint;
@property (readonly) SegmentSelector* segmentSelector;
@property (readwrite, assign) NSArrayController* tracksController;

@end
