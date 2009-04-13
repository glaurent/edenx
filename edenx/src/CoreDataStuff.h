//
//  CoreDataStuff.h
//  edenx
//
//  Created by Guillaume Laurent on 4/13/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Track CoreData u
@interface NSManagedObject (Track)

@property (retain) NSNumber * channel;
@property (retain) NSString * name;

@end


@interface NSManagedObject (Element)

@property (retain) NSNumber * absoluteTime;

@end

@interface NSManagedObject (Note)

@property (retain) NSNumber * duration;
@property (retain) NSNumber * note;
@property (retain) NSNumber * velocity;

@end
