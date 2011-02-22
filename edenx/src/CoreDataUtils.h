//
//  CoreDataUtils.h
//  edenx
//
//  Created by Guillaume Laurent on 4/25/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CoreDataUtils : NSObject {
    NSSortDescriptor* absoluteTimeSortDescriptor;
    NSArray* absoluteTimeSortDescriptorArray;
}

- (NSArray*) absoluteTimeSortDescriptorArray;
// + (CoreDataUtils*) instance;

@property(readonly) NSArray* absoluteTimeSortDescriptorArray;

@end