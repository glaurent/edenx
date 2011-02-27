//
//  CoreDataStuff.h
//  edenx
//
//  Created by Guillaume Laurent on 4/13/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef long timeT;

// Composition CoreData
@protocol Composition<NSObject>

- (void)addTemposObject:(NSManagedObject *)value;
- (void)removeTemposObject:(NSManagedObject *)value;
- (void)addTempos:(NSSet *)value;
- (void)removeTempos:(NSSet *)value;
- (void)addTimeSignaturesObject:(NSManagedObject *)value;
- (void)removeTimeSignaturesObject:(NSManagedObject *)value;
- (void)addTimeSignatures:(NSSet *)value;
- (void)removeTimeSignatures:(NSSet *)value;



@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSNumber* tempo;
@property (nonatomic, retain) NSNumber* loopStart;
@property (nonatomic, retain) NSNumber* loopEnd;
@property (nonatomic, retain) NSNumber* startMarker;
@property (nonatomic, retain) NSNumber* endMarker;
@property (nonatomic, retain) NSNumber* playbackPosition;
@property (nonatomic, retain) NSMutableSet* tempos;
@property (nonatomic, retain) NSMutableSet* timeSignatures;

@end



// Track CoreData

@protocol Track<NSObject>

- (void)addSegmentsObject:(id)Object;

@property (nonatomic, retain) NSNumber * channel;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id inputSource;
@property (nonatomic, retain) NSMutableSet* segments;

@end

// Segment CoreData

@protocol Segment<NSObject>

- (void)addEventsObject:(id)Object;
@property (nonatomic, retain) NSNumber * startTime;
@property (nonatomic, retain) NSNumber * endTime;
@property (nonatomic, retain) NSMutableSet* events;
@property (nonatomic, retain) id track;

@end



// Element CoreData

@protocol Element<NSObject>

@property (nonatomic, retain) NSNumber * absoluteTime;

@end

// Note CoreData

@protocol Note<Element>

@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * note;
@property (nonatomic, retain) NSNumber * velocity;

@end


@protocol TimeSignature<NSObject>

@property (nonatomic, retain) NSNumber * absoluteTime;
@property (nonatomic, retain) NSNumber * numerator;
@property (nonatomic, retain) NSNumber * denominator;

@property (nonatomic, retain) NSNumber * barNumber;

// booleans
@property (nonatomic, retain) NSNumber * dotted;
@property (nonatomic, retain) NSNumber * common;
@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) NSNumber * hiddenBars;

@property (nonatomic, retain) NSManagedObject * composition;

@end

@protocol Tempo<NSObject>

@property (nonatomic, retain) NSNumber * absoluteTime;
@property (nonatomic, retain) NSNumber * tempo;
@property (nonatomic, retain) NSManagedObject * composition;

@end


