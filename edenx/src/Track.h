//
//  Track.h
//  edenx
//
//  Created by Guillaume Laurent on 1/14/12.
//  Copyright (c) 2012 telegraph-road.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Track : NSManagedObject

//@property UNKNOWN_TYPE UNKNOWN_TYPE inputSource;
@property (nonatomic) int16_t channel;
@property (nonatomic) BOOL recording;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t index;
@property (nonatomic, retain) NSSet *segments;
@property (nonatomic, retain) NSManagedObject *composition;
@end

@interface Track (CoreDataGeneratedAccessors)

- (void)addSegmentsObject:(NSManagedObject *)value;
- (void)removeSegmentsObject:(NSManagedObject *)value;
- (void)addSegments:(NSSet *)values;
- (void)removeSegments:(NSSet *)values;

@end
