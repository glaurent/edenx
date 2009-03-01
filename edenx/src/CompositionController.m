//
//  CompositionController.m
//  edenx
//
//  Created by Guillaume Laurent on 3/1/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import "CompositionController.h"


@implementation CompositionController

- (void)prepareContent
{
    
    NSLog(@"CompositionController:prepareContent");
    
    [super prepareContent];
    
    // check if there's an entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *fetchError = nil;
    NSArray *fetchResults;
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Composition"
                                              inManagedObjectContext:moc];
    
    [fetchRequest setEntity:entity];
    fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
    
    if ((fetchResults != nil) && ([fetchResults count] == 1) && (fetchError == nil))
    {
        NSLog(@"CompositionController:prepareContent - super found an entity - nothing to do");
    } else {
        NSLog(@"CompositionController:prepareContent - create new Composition instance");
        
        [NSEntityDescription insertNewObjectForEntityForName:@"Composition"
                                      inManagedObjectContext:moc];
        
        // To avoid undo registration for this insertion, removeAllActions on the undoManager.
        // First call processPendingChanges on the managed object context to force the undo registration
        // for this insertion, then call removeAllActions.
        [moc processPendingChanges];
        [[moc undoManager] removeAllActions];        
    }
    
}



@end
