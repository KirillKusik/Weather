#import "TSCoreDataDB.h"

@implementation TSCoreDataDB
@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;

-(BOOL) addRecordToDatabase:(NSDictionary *)dictionary{
    NSManagedObject *weather;
    weather = [NSEntityDescription insertNewObjectForEntityForName:kDatabaseTableName inManagedObjectContext:self.managedObjectContext];
    [weather setValue:[dictionary objectForKey:kDatabaseKey_City] forKey:kDatabaseKey_City];
    [weather setValue:[dictionary objectForKey:kDatabaseKey_Code] forKey:kDatabaseKey_Code];
    [weather setValue:[dictionary objectForKey:kDatabaseKey_Date] forKey:kDatabaseKey_Date];
    NSNumber *tempValue = [NSNumber numberWithInteger:[[dictionary objectForKey:kDatabaseKey_Temp] integerValue]];
    [weather setValue:tempValue forKey:kDatabaseKey_Temp];
    [weather setValue:[dictionary objectForKey:kDatabaseKey_Text] forKey:kDatabaseKey_Text];
    
    [self saveContext];
    [self refresh];
    [self removeUnneededRecords];
    [self refresh];
    return YES;
}

-(void) removeUnneededRecords{
    
    for (NSInteger i = 0; [linsArray count] > [[TSSettings sharedController] limitRecordsInDatabase]; i++) {
        NSDictionary * recordFoDeleted = [linsArray objectAtIndex:0];
        [self deleteRecordFromDatabase:[recordFoDeleted objectForKey:@"id"]];
    }
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
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}


// ОбЪектная модель базы данных
- (NSManagedObjectModel *)managedObjectModel{
    //если обЪект не уже сушествует завершаем метод
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TSCoreData" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}


//Координатор персистентного хранилища.
//Здесь на страиваются актуальные имена для работы с базой
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    //если обЪект не уже сушествует завершаем метод
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TSCoreData.sqlite"];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil]) {
        [self generateErrorWithErrorMessage:@"Persistent store error" Description:@"<#string#>"]
        abort();
    }
    
    return persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


-(void)generateErrorWithErrorMessage:(NSString *)message Description:(NSString *)description{
    [self generateErrorWithDomain:@"CoreData" ErrorMessage:message Description:description];
}
@end
