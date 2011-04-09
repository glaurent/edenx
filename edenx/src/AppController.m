//
//  AppController.m
//  edenx
//
//  Created by Guillaume Laurent on 2/15/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "AppController.h"
#import "Player.h"
#import "Recorder.h"

@implementation AppController

- (id)init
{
    self = [ super init ];
    NSLog(@"AppController init");

    // Init player in applicationWillFinishLaunching
    player = nil;
    
    return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"AppController:applicationWillFinishLaunching");
    
    player = [[Player alloc] init];
    [recorder setup];
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    NSLog(@"AppController:applicationDidFinishLaunching");
    
}


@synthesize recorder;
@synthesize player;

@end
