#import "TSWeatherCoreData.h"
#import <CoreData/CoreData.h>
#import "TSWeather.h"

static NSString *const kDatabaseName = @"TSWeatherDatabase";

@interface TSWeatherCoreData ()
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSError *error;
@end

@implementation TSWeatherCoreData

#pragma mark - Methods of adding, deleting, and getting the content database
-(BOOL)addWeather:(TSWeather *)weather {
    NSManagedObject *weatherToInsert = [NSEntityDescription insertNewObjectForEntityForName:kDatabaseTableName
            inManagedObjectContext:self.managedObjectContext];
    [weatherToInsert setValue:weather.city forKey:kDatabaseKey_City];
    [weatherToInsert setValue:weather.code forKey:kDatabaseKey_Code];
    [weatherToInsert setValue:weather.date forKey:kDatabaseKey_Date];
    [weatherToInsert setValue:weather.temp forKey:kDatabaseKey_Temp];
    [weatherToInsert setValue:weather.text forKey:kDatabaseKey_Text];
    [self saveContext];
    if ([self searchWeatherRecordInDatabase:weather]) {
        return YES;
    } else {
        [self generateErrorWithDomain:@"Core Data Error" ErrorMessage:@"Write error"
                Description:@"The record is not added to the database"];
        return NO;
    }
}


-(BOOL)deleteWeather:(TSWeather *)weather {
    NSManagedObject *weatherToDelete = [self searchWeatherRecordInDatabase:weather];
    if (weatherToDelete) {
        [self.managedObjectContext deleteObject:weatherToDelete];
        [self saveContext];
        return YES;
    } else {
        [self generateErrorWithDomain:@"Core Data Error" ErrorMessage:@"Unable to find the object to remove"
                Description:@"A request for a given object returned an empty result"];
        return NO;
    }
}

-(NSManagedObject *)searchWeatherRecordInDatabase:(TSWeather *)weather {
    NSEntityDescription *entityDesctiption = [NSEntityDescription entityForName: kDatabaseTableName
                                                         inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(%K = %@ ) and (%K = %@ ) and (%K = %@ ) and (%K = %@ ) and (%K = %@ )", kDatabaseKey_City, weather.city,
                              kDatabaseKey_Code, weather.code, kDatabaseKey_Date, weather.date, kDatabaseKey_Temp, weather.temp,
                              kDatabaseKey_Text, weather.text];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesctiption];
    [request setPredicate:predicate];
    NSArray *objectsFromDatabase = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ([objectsFromDatabase count] > 0) {
        return [objectsFromDatabase firstObject];
    } else {
        return nil;
    }
}

-(NSArray *)getWeatherArray {
    NSEntityDescription *entity = [NSEntityDescription entityForName:kDatabaseTableName
            inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSArray *resaltRequest = [self.managedObjectContext executeFetchRequest:fetchRequest
            error:nil];
    if (resaltRequest != nil) {
        NSMutableArray *weatherArray = [[NSMutableArray alloc] init];
        for (NSManagedObject *extractedObject in resaltRequest) {
            TSWeather *weather = [[TSWeather alloc]
                    initWithNameOfCity: [extractedObject valueForKeyPath:kDatabaseKey_City]
                    code:[extractedObject valueForKeyPath:kDatabaseKey_Code]
                    date:[extractedObject valueForKeyPath:kDatabaseKey_Date]
                    temp:[extractedObject valueForKeyPath:kDatabaseKey_Temp]
                    text:[extractedObject valueForKeyPath:kDatabaseKey_Text]];
            [weatherArray addObject:weather];
        }
        return weatherArray;
    } else {
        [self generateErrorWithDomain:@"Core Data Error" ErrorMessage:@"Read error"
                Description:@"The query result was empty"];
        return nil;
    }
}

#pragma mark - Change database settings
-(void)setCountRecords:(NSUInteger)count {
    NSArray *weatherArray = [self getWeatherArray];
    if (count < [weatherArray count]) {
        for (NSInteger index = 0; index < ([weatherArray count] - count); index++) {
            TSWeather *weatherToDelete = [weatherArray objectAtIndex:index];
            [self deleteWeather:weatherToDelete];
        }
    }
}

#pragma mark - Core Data metods
- (void)saveContext {
    NSError *errorMessage = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&errorMessage]) {
            NSLog(@"Unresolved error %@, %@", errorMessage, [errorMessage userInfo]);
            self.error = errorMessage;
        }
    }
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kDatabaseName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
            initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"testCoreData.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL
            options:nil error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Generate Error metod
-(void)generateErrorWithDomain:(NSString *)domain ErrorMessage:(NSString *)message
        Description:(NSString *)description {
    NSArray *objArray = [NSArray arrayWithObjects:description, message, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    self.error = [NSError errorWithDomain:domain code:1 userInfo:userInfo];
}

@end
