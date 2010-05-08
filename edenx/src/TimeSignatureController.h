//
//  TimeSignatureController.h
//  edenx
//
//  Created by Guillaume Laurent on 3/18/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//  Copyright 2000-2009 the Rosegarden development team.
//

#import <Cocoa/Cocoa.h>
#import "CoreDataStuff.h"

@interface TimeSignatureController : NSObject {

    NSManagedObject<TimeSignature>* timeSignature;
    BOOL durationsSet;
    uint barDuration;
    uint beatDuration;
    uint beatDivisionDuration;
    BOOL dotted;
}

+ (timeT)defaultBarDuration:(NSManagedObjectContext*)managedObjectContext;
+ (void)createDefaultTimeSignature:(NSManagedObjectContext*)managedObjectContext;
+ (NSManagedObject<TimeSignature>*)defaultTimeSignature:(NSManagedObjectContext*)managedObjectContext;

- (id)initWithTimeSignature:(NSManagedObject<TimeSignature>*)t;
- (void)setTimeSignature:(NSManagedObject<TimeSignature>*)t;
- (timeT)unitDuration;
- (BOOL)dotted;
- (timeT)barDuration;
- (timeT)beatDuration;
- (uint)beatsPerBar;
- (void)addDurationListForBarInArray:(NSMutableArray*)durations;
- (void)addDurationListForInterval:(uint)duration withStartOffset:(uint)startOffset inArray:(NSMutableArray*)durations;
- (uint)emphasisForTime:(timeT) offset;
- (void)addDivisions:(uint)depth inArray:(NSMutableArray*)divisions;

- (void)setInternalDurations;

@end
