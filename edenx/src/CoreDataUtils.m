//
//  CoreDataUtils.m
//  edenx
//
//  Created by Guillaume Laurent on 4/25/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//

#import "CoreDataUtils.h"


@implementation CoreDataUtils

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        absoluteTimeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"absoluteTime" ascending:YES];
        absoluteTimeSortDescriptorArray = [NSArray arrayWithObject:absoluteTimeSortDescriptor];        

        trackSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        trackSortDescriptorArray = [NSArray arrayWithObject:trackSortDescriptor];
    }
    
    return self;
}

//+ (CoreDataUtils*) instance
//{
//    static CoreDataUtils* myInstance = nil;
//    
//    if (myInstance == nil) {
//        myInstance = [[CoreDataUtils alloc] init];
//    }
//    
//    return myInstance;
//}
//
//+ (NSArray*) absoluteTimeSortDescriptorArray
//{
//    return [[CoreDataUtils instance] absoluteTimeSortDescriptorArrayDataMember];
//}

@synthesize absoluteTimeSortDescriptorArray;
@synthesize trackSortDescriptorArray;

@end
