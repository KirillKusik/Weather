//
//  TSAppDelegate.m
//  Weather
//
//  Created by Admin on 13.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSAppDelegate.h"
#import "TSSettings.h"
@implementation TSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize linsArray;

-(instancetype)init{
    self = [super init];
    if (self){
        [self refresh];
    }
    return self;
}
-(void) removeUnneededRecords{
    
    for (NSInteger i = 0; [linsArray count] > [[TSSettings sharedController] DBCount]; i++) {
        NSDictionary * recordFoDeleted = [linsArray objectAtIndex:0];        
        [self deleteRecordFromDatabase:[recordFoDeleted objectForKey:@"id"]];
    }
}

-(BOOL) addRecordToDatabase:(NSDictionary *)dictionary{
    
    NSManagedObject *weather = [NSEntityDescription insertNewObjectForEntityForName:@"Weather" inManagedObjectContext:self.managedObjectContext];
    [weather setValue:[dictionary objectForKey:@"city"] forKey:@"city"];
    [weather setValue:[dictionary objectForKey:@"code"] forKey:@"code"];
    [weather setValue:[dictionary objectForKey:@"date"] forKey:@"date"];
    [weather setValue:[NSNumber numberWithInteger:[[dictionary objectForKey:@"temp"] integerValue]] forKey:@"temp"];
    [weather setValue:[dictionary objectForKey:@"text"] forKey:@"text"];
    
    [self saveContext];
    [self refresh];
    [self removeUnneededRecords];
    [self refresh];
    return YES;
}

-(BOOL) refresh{
    NSFetchRequest *featchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Weather"];
    NSArray *allData = [self.managedObjectContext executeFetchRequest:featchRequest error:nil];
    linsArray = [NSMutableArray new];
    for (NSManagedObject *line in allData) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setValue:[line valueForKey:@"city"] forKey:@"city"];
        [dic setValue:[line valueForKey:@"code"] forKey:@"code"];
        [dic setValue:[line valueForKey:@"date"] forKey:@"date"];
        [dic setValue:[line valueForKey:@"temp"] forKey:@"temp"];
        [dic setValue:[line valueForKey:@"text"] forKey:@"text"];
        [dic setValue:[line objectID] forKey:@"id"];
        
        
        [linsArray addObject: dic];
    }
    return YES;
}

-(BOOL) deleteRecordFromDatabase:(NSManagedObjectID *)id{
    [self.managedObjectContext deleteObject:[self.managedObjectContext objectWithID:id]];
    [self saveContext];
    [self refresh];
    
    return YES;
}




- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TSCoreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TSCoreData.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [TSSettings sharedController];
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
