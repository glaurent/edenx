//
//  CoreDataStuff.h
//  edenx
//
//  Created by Guillaume Laurent on 4/13/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Composition CoreData
@protocol Composition

@property (retain) NSString* name;
@property (retain) NSNumber* tempo;

@end


// Track CoreData

@protocol Track

- (void)addEventsObject:(id)Object;

@property (retain) NSNumber * channel;
@property (retain) NSString * name;
@property (retain) id inputSource;
@property (retain) NSMutableSet* events;

@end

// Element CoreData

@protocol Element

@property (retain) NSNumber * absoluteTime;

@end

// Note CoreData

@protocol Note<Element>

@property (retain) NSNumber * duration;
@property (retain) NSNumber * note;
@property (retain) NSNumber * velocity;

@end
