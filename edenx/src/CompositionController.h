//
//  CompositionController.h
//  edenx
//
//  Created by Guillaume Laurent on 3/1/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CompositionController : NSObjectController {

}

// override prepareContent to ensure a Composition is there
//
- (void)prepareContent;

@end
