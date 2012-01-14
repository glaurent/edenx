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

    CGPoint mouseDownPoint;
    CGPoint previousMouseDownPoint;
    unsigned int rectHeight;
    id rectangleLayerDelegate;
    BOOL forgetSegmentTimeChanges;
    BOOL forgetSegmentAdd; // set to YES on initial segment creation in mouseUp
    
    CGColorRef rectFillColor;
    CGColorRef rectBorderColor;
    CGColorRef rectHandleColor;
    CGColorRef redColor;
    CGColorRef blueColor;
    
    CALayer* hitLayer;
    CALayer* hitHandleLayer;
    CALayer* hitRectLayer;
    CALayer* hitStripLayer;
    float mouseDownXOffset;
    
}

- (void)addStripLayerForTracks:(NSArray*)tracks;
- (CALayer*)addStripLayerForNewTrack:(NSManagedObject<Track>*)track;
- (CALayer*)addStripLayerForTrack:(NSManagedObject<Track>*)track atIndex:(uint)index;
- (id)addRectangleForSegment:(NSManagedObject<Segment>*)segment inTrack:(NSManagedObject<Track>*)associatedTrack;

@property (readonly) unsigned int rectHeight;
@property (readwrite, strong) CALayer* containerLayerForRectangles;
@property (readwrite, assign) CGPoint mouseDownPoint;
@property (readonly, strong) SegmentSelector* segmentSelector;
@property (readwrite, strong) NSArrayController* tracksController;

@end
