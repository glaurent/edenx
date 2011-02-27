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

    NSSortDescriptor* trackSortDescriptor;
    NSArray* trackSortDescriptorArray;
}

- (NSArray*) absoluteTimeSortDescriptorArray;
// + (CoreDataUtils*) instance;

@property(readonly) NSArray* absoluteTimeSortDescriptorArray;
@property(readonly) NSArray* trackSortDescriptorArray;

@end
