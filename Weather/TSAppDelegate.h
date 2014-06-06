//
//  TSAppDelegate.h
//  Weather
//
//  Created by Admin on 13.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface TSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly,nonatomic) NSMutableArray *linsArray;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


-(void) removeUnneededRecords;
-(BOOL) addRecordToDatabase:(NSDictionary *) dictionary;
-(BOOL) deleteRecordFromDatabase:(NSManagedObjectID *)id;
-(BOOL) refresh;
@end
