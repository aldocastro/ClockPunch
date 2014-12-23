//
//  AppDelegate.h
//  ClockPunch
//
//  Created by Aldo Castro on 10/12/14.
//  Copyright (c) 2014 Aldo Castro. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreData;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

