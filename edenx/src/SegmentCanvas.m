//
//  SegmentCanvas.m
//  edenx
//
//  Created by Guillaume Laurent on 6/6/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//

#import "SegmentCanvas.h"
#import "SegmentLayerDelegate.h"
#import "SegmentSelector.h"
#import "CoreDataStuff.h"

@implementation SegmentCanvas

- (id)initWithFrame:(NSRect)frame
{
    NSLog(@"SegmentCanvas:initWithFrame");
    
    if ( self = [super initWithFrame:frame] )
    {
        rectHeight = 40;
        rectangleLayerDelegate = [[SegmentLayerDelegate alloc] init];
        
        rectFillColor = CGColorCreateGenericRGB(0.2, 1.0, 0.3, 0.5); // greenish 
        CFMakeCollectable(rectFillColor);
        rectBorderColor = CGColorCreateGenericRGB(0.3, 0.4, 0.4, 0.8); // more saturated greenish ?
        CFMakeCollectable(rectBorderColor);
        rectHandleColor = CGColorCreateGenericRGB(0.3, 0.5, 0.5, 0.8); 
        CFMakeCollectable(rectBorderColor);
        
        // test colors
        redColor = CGColorCreateGenericRGB(1.0, 0.0, 0.0, 0.5);
        CFMakeCollectable(redColor);
        blueColor = CGColorCreateGenericRGB(0.0, 0.0, 1.0, 0.8);
        CFMakeCollectable(blueColor);
        
        segmentSelector = [[SegmentSelector alloc] init];
        
        hitLayer = hitHandleLayer = hitRectLayer = nil;
        
    }
    return self;
}


// Layers :
// - main layer
//    - cursor layer (see that later)
//    - container layer for rects
//        - strip layer 1
//          - layer for rect 1
//          - layer for rect 2
//          - ...
//        - strip layer 2
//          - layer for rect 
//          - layer for rect 
//          - ...
//        - ...
///

- (void)awakeFromNib
{
    NSLog(@"SegmentCanvas:awakeFromNib");
   
    // become the delegate for the layer
    CALayer* mainLayer = self.layer;
    mainLayer.name = @"mainLayer";    
    
    // create container layer for rects
    containerLayerForRectangles = [CALayer layer];
    containerLayerForRectangles.name = @"rectanglesContainer";
    containerLayerForRectangles.geometryFlipped = YES;
    [containerLayerForRectangles setValue:[NSValue valueWithPointer:rectFillColor] forKey:@"segmentFillColor"];
    mainLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
    
    NSLog(@"mainLayer.bounds : %f,%f w=%f, h=%f", mainLayer.bounds.origin.x, mainLayer.bounds.origin.y, mainLayer.bounds.size.width, mainLayer.bounds.size.height);
    
    [containerLayerForRectangles addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:@"superlayer" attribute:kCAConstraintMidX]];
    [containerLayerForRectangles addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:@"superlayer" attribute:kCAConstraintMidY]];
    [containerLayerForRectangles addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth relativeTo:@"superlayer" attribute:kCAConstraintWidth]];
    [containerLayerForRectangles addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight relativeTo:@"superlayer" attribute:kCAConstraintHeight]];
    containerLayerForRectangles.autoresizingMask |= kCALayerWidthSizable;
    containerLayerForRectangles.borderColor = blueColor;
    containerLayerForRectangles.borderWidth = 1;
    //    mainLayer.borderColor = blueColor;
    //    mainLayer.borderWidth = 1;
    
    [mainLayer addSublayer:containerLayerForRectangles];
    
    //    [containerLayerForRectangles setNeedsLayout];
    //    [mainLayer layoutIfNeeded];
    NSLog(@"containerLayerForRectangles.bounds : %f,%f w=%f, h=%f - position: %f,%f",
          containerLayerForRectangles.bounds.origin.x, containerLayerForRectangles.bounds.origin.y, containerLayerForRectangles.bounds.size.width, containerLayerForRectangles.bounds.size.height,
          containerLayerForRectangles.position.x, containerLayerForRectangles.position.y);
    NSLog(@"containerLayerForRectangles.frame : %f,%f w=%f, h=%f", containerLayerForRectangles.frame.origin.x, containerLayerForRectangles.frame.origin.y, containerLayerForRectangles.frame.size.width, containerLayerForRectangles.frame.size.height);
    
    containerLayerForRectangles.layoutManager = [CAConstraintLayoutManager layoutManager];
    
}

- (void)addStripLayerForTracks:(NSArray*)tracks
{
    for(NSManagedObject<Track>* track in tracks) {
        [self addStripLayerForTrack:track];
    }
}

- (CALayer*)addStripLayerForTrack:(NSManagedObject<Track>*)track
{
//    NSLog(@"addStripLayerForTrack : tracksArrayController content : %@ - arrangedObjects : %@",
//          [tracksArrayController content], [tracksArrayController arrangedObjects]);
    uint nbTracks = [[tracksArrayController arrangedObjects] count];
    uint newTrackIndex = nbTracks; // WHAT TO DO WHEN TRACKS ARE REMOVED ?
    
    CALayer* stripLayer = [CALayer layer];
    [stripLayer setValue:track forKey:@"track"];
    
    track.associatedCALayer = stripLayer;
    
    CGFloat y = (newTrackIndex * rectHeight) + rectHeight / 2;
    NSLog(@"adding a strip layer for track index %d at %f", newTrackIndex, y);
    stripLayer.name = [NSString stringWithFormat:@"stripLayer%d", newTrackIndex];
    stripLayer.bounds = CGRectMake ( 0.0, 0.0, 0.0, rectHeight );
    stripLayer.position = CGPointMake(0.0, y);
    stripLayer.borderColor = redColor;
    stripLayer.borderWidth = 1;
    stripLayer.autoresizingMask |= kCALayerWidthSizable;
    [stripLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:@"superlayer" attribute:kCAConstraintMidX]];
    [stripLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth relativeTo:@"superlayer" attribute:kCAConstraintWidth]];
    
    stripLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
    [containerLayerForRectangles addSublayer:stripLayer];
    
    [stripLayer setNeedsDisplay];
    
    return stripLayer;        
}

- (void)addSegmentRectangle:(CGPoint)origin inStripLayer:(CALayer*)stripLayer
{
    // create layer for rect
    //
    CALayer* rectLayer = [CALayer layer];
    NSLog(@"containerLayerForRectangles.bounds.size.width : %f", containerLayerForRectangles.bounds.size.width);
    rectLayer.name = @"rectLayer";
    rectLayer.bounds = CGRectMake ( 0.0, 0.0, 100 , rectHeight ); // default widht = 100
    rectLayer.position = origin;
    rectLayer.delegate = rectangleLayerDelegate;
    rectLayer.cornerRadius = 8;
    rectLayer.backgroundColor = rectFillColor;
    rectLayer.borderColor = rectBorderColor;
    rectLayer.borderWidth = 2;
    //    [rectLayer setValue:[NSNumber numberWithFloat:100.0] forKey:@"segmentWidth"]; // set default length
    //    [rectLayer setValue:[NSNumber numberWithFloat:origin.x] forKey:@"segmentStart"]; // set start
    
    [rectLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY
                                                        relativeTo:@"superlayer"
                                                         attribute:kCAConstraintMidY]];
    [rectLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight
                                                        relativeTo:@"superlayer"
                                                         attribute:kCAConstraintHeight]];
    
    
    [stripLayer addSublayer:rectLayer];
    rectLayer.layoutManager=[CAConstraintLayoutManager layoutManager];
    
    // add size handles
    
    CALayer* leftHandleLayer = [CALayer layer];
    leftHandleLayer.name = @"leftHandleLayer";
    leftHandleLayer.bounds = CGRectMake ( 0, 0, 10, 10 );
    leftHandleLayer.cornerRadius = 3;
    leftHandleLayer.backgroundColor = rectHandleColor;
    leftHandleLayer.borderColor = rectHandleColor;
    leftHandleLayer.borderWidth = 1;
    
    [leftHandleLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY
                                                              relativeTo:@"superlayer"
                                                               attribute:kCAConstraintMidY]];
    [leftHandleLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX
                                                              relativeTo:@"superlayer"
                                                               attribute:kCAConstraintMinX]];
    [rectLayer addSublayer:leftHandleLayer];
    
    CALayer* rightHandleLayer = [CALayer layer];
    rightHandleLayer.name = @"rightHandleLayer";
    rightHandleLayer.bounds = CGRectMake ( 0, 0, 10, 10 );
    rightHandleLayer.cornerRadius = 3;
    rightHandleLayer.backgroundColor = rectHandleColor;
    rightHandleLayer.borderColor = rectHandleColor;
    rightHandleLayer.borderWidth = 1;
    
    [rightHandleLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY
                                                               relativeTo:@"superlayer"
                                                                attribute:kCAConstraintMidY]];
    [rightHandleLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX
                                                               relativeTo:@"superlayer"
                                                                attribute:kCAConstraintMaxX]];
    
    [rectLayer addSublayer:rightHandleLayer];
    
    [stripLayer setNeedsLayout];
    [rectLayer setNeedsDisplay];
    
    // TODO - create Segment, add it in model - use Segment's NSArrayController in MyDocument
    
}

- (void)mouseDown:(NSEvent*)aEvent
{    
    NSLog(@"mouseDown at %@", NSStringFromPoint([aEvent locationInWindow]));
    // convert to local coordinate system
    NSPoint mousePointInView = [self convertPoint:[aEvent locationInWindow] fromView:nil];
    
    NSLog(@"mouseDown point converted to %@", NSStringFromPoint(mousePointInView));
    
    // convert to CGPoint for convenience
    CGPoint cgMousePointInView = NSPointToCGPoint(mousePointInView);
    
    // save the original mouse down as a instance variable, so that we
    // can start a new animation from here, if necessary.
    mouseDownPoint = previousMouseDownPoint = cgMousePointInView;
    
    // check if user clicked on a layer
    //
    hitHandleLayer = hitRectLayer = hitStripLayer = nil;
    hitLayer = [containerLayerForRectangles hitTest:mouseDownPoint];
    
    if (hitLayer) {
        NSLog(@"clicked on layer %@", hitLayer.name);
        
        if ([hitLayer.name hasSuffix:@"HandleLayer"]) {
            hitHandleLayer = hitLayer;
            hitRectLayer = hitLayer.superlayer;
        } else if ([hitLayer.name isEqual:@"rectLayer"]) {
            hitRectLayer = hitLayer;
            mouseDownXOffset = mouseDownPoint.x - hitRectLayer.position.x;
        } else if ([hitLayer.name hasPrefix:@"stripLayer"]) {
            NSLog(@"hit strip layer");
            hitStripLayer = hitLayer;
        }
    }
    
}

- (void)mouseUp:(NSEvent*)aEvent
{
    if (hitStripLayer) {
        [self addSegmentRectangle:[containerLayerForRectangles convertPoint:mouseDownPoint toLayer:hitStripLayer] inStripLayer:hitStripLayer];
        [self.layer setNeedsDisplay];        
    } else if (hitRectLayer && !hitHandleLayer) {
        [segmentSelector setCurrentSelectedSegment:hitRectLayer];
    } else {
        // forget clicked layer
        hitLayer = hitHandleLayer = hitRectLayer = nil;
    }
    
}

- (void)mouseDragged:(NSEvent*)theEvent
{
    [[self superview] autoscroll:theEvent];
    
    if (hitLayer) {
        
        // convert to local coordinate system
        NSPoint mousePointInView = [self convertPoint:theEvent.locationInWindow fromView:nil];
        
        // convert to CGPoint for convenience
        CGPoint cgMousePointInView = NSPointToCGPoint(mousePointInView);
        
        // save the original mouse down as a instance variables, so that we
        // can start a new animation from here, if necessary.
        mouseDownPoint = cgMousePointInView;
        
        if (hitRectLayer && !hitHandleLayer) {
            
            [CATransaction begin];
            
            [CATransaction setValue: [NSNumber numberWithFloat:0.0]
                             forKey: kCATransactionAnimationDuration];
            
            hitRectLayer.position = CGPointMake(mouseDownPoint.x - mouseDownXOffset, hitRectLayer.position.y);
            
            [CATransaction commit];
            
            
        } else if (hitHandleLayer) {
            
            [CATransaction begin];
            
            [CATransaction setValue: [NSNumber numberWithFloat:0.0]
                             forKey: kCATransactionAnimationDuration];
            
            CGRect currentFrame = hitRectLayer.frame;
            //CGPoint hitHandleLayerPositionInRect = [containerLayerForRectangles convertPoint:hitHandleLayer.position fromLayer:hitHandleLayer];
            //NSLog(@"mouseDownPoint.x : %f | hitHandleLayer.position.x : %f", mouseDownPoint.x, hitHandleLayerPositionInRect.x);
            float deltaWidth = mouseDownPoint.x - previousMouseDownPoint.x;
            
            //NSLog(@"current frame : %f,%f w=%f, h=%f", currentFrame.origin.x, currentFrame.origin.y, currentFrame.size.width, currentFrame.size.height);
            
            if ([hitHandleLayer.name isEqualToString:@"leftHandleLayer"]) {
                //NSLog(@"left handle move : current width : %f | delta : %f", currentFrame.size.width, deltaWidth);
                hitRectLayer.frame = CGRectMake(mouseDownPoint.x, currentFrame.origin.y, currentFrame.size.width - deltaWidth, currentFrame.size.height);                
            } else {
                //NSLog(@"right handle move : current width : %f | delta : %f", currentFrame.size.width, deltaWidth);
                hitRectLayer.frame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y, currentFrame.size.width + deltaWidth, currentFrame.size.height);                
            }
            
            
            [CATransaction commit];
            
        }
        
        previousMouseDownPoint = mouseDownPoint;
        
    }
    
    
}

// DEBUG
- (IBAction)showCoordinates:(id)sender
{
    NSLog(@"showCoordinates");
    NSLog(@"layout manager : %@", containerLayerForRectangles.layoutManager);
    for(CALayer* layer in containerLayerForRectangles.sublayers) {
        NSLog(@"%@ : %f,%f w=%f, h=%f", layer.name, layer.position.x, layer.position.y, layer.bounds.size.width, layer.bounds.size.height);
        for(CAConstraint* constraint in layer.constraints) {
            NSLog(@"attribute : %d - sourceAttribute : %d - sourceName : %@", constraint.attribute, constraint.sourceAttribute, constraint.sourceName);
        }
    }
}

- (void)resetStripLayersYCoordinates:(NSArray*)tracks withRemovedTracks:(NSSet*)removedTracks
{
    NSLog(@"SegmentCanvas:resetStripLayersYCoordinates");
    [CATransaction begin];
    
    [CATransaction setValue: [NSNumber numberWithFloat:1.0]
                     forKey: kCATransactionAnimationDuration];

    int idx = 0;
    for(NSManagedObject<Track>* track in tracks) {
        if ([removedTracks containsObject:track])
            continue; // skip removed tracks
        
        CGFloat y = (idx * rectHeight) + rectHeight / 2;
        NSLog(@"y = %f", y);
        CALayer* stripLayer = track.associatedCALayer;
        stripLayer.position = CGPointMake(0.0, y);
        ++idx;        
    }
    
    [CATransaction commit];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"SegmentCanvas:observeValueForKeyPath %@", keyPath);
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    NSLog(@"newValue = %@", newValue);
    NSLog(@"oldValue = %@", [change objectForKey:NSKeyValueChangeOldKey]);
    
    if ([keyPath isEqual:@"tracks"]) {
        NSLog(@"SegmentCanvas:observeValueForKeyPath - tracks change");

        NSMutableSet* newTracks = [NSMutableSet setWithSet:newValue];
        [newTracks minusSet:oldValue];
        
        NSMutableSet* removedTracks = [NSMutableSet setWithSet:oldValue];
        [removedTracks minusSet:newValue];
        
        for(NSManagedObject<Track>* removedTrack in removedTracks) {
            CALayer* stripLayer = removedTrack.associatedCALayer;
            NSLog(@"SegmentCanvas:observeValueForKeyPath - removing layer %@ associated to track %@", stripLayer, removedTrack);
            [stripLayer removeFromSuperlayer];
            [self resetStripLayersYCoordinates:[tracksArrayController arrangedObjects] withRemovedTracks:removedTracks];
        }
        for(NSManagedObject<Track>* addedTrack in newTracks) {
            NSLog(@"SegmentCanvas:observeValueForKeyPath - adding strip layer for track %@", addedTrack);
            [self addStripLayerForTrack:addedTrack];
        }
        
        
    } else if ([keyPath isEqual:@"zoomVertical"]) {
        // TODO - do zooming better
        float scaleFactor = [newValue floatValue];
        
        CATransform3D scale = CATransform3DMakeScale(scaleFactor, scaleFactor, 0.0);
        containerLayerForRectangles.transform = scale;
        // use a transaction to smooth the zooming ?        
    }

    
}

// this was to try observing changes on added/removed tracks, but it doesn't work
// instead I have to observe the to-many relationship Composition->>tracks
//
//- (NSArrayController*)tracksArrayController
//{
//    return tracksArrayController;
//}
//
//- (void)setTracksArrayController:(NSArrayController*)controller
//{
//    if (tracksArrayController != nil) {
//        [tracksArrayController removeObserver:self forKeyPath:@"arrangedObjects"];
//    }
//    tracksArrayController = controller;
//    [tracksArrayController addObserver:self 
//                            forKeyPath:@"arrangedObjects"
//                               options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
//                               context:NULL];
//}

//- (void)drawRect:(NSRect)r 
//{
//    NSLog(@"CompositionViewProto:drawRect %f,%f - w=%f, h=%f", r.origin.x, r.origin.y, r.size.width, r.size.height);
//    [super drawRect:r];
//}
//
//- (void)reflectScrolledClipView:(NSClipView *)aClipView
//{
//    NSRect r = [aClipView documentRect];
//    NSLog(@"CompositionViewProto:reflectScrolledClipView documentRect %f,%f - w=%f, h=%f", r.origin.x, r.origin.y, r.size.width, r.size.height);
//    [super reflectScrolledClipView:aClipView];
//}

@synthesize rectHeight;
@synthesize containerLayerForRectangles;
@synthesize mouseDownPoint;
@synthesize segmentSelector;
@synthesize tracksArrayController;

@end
