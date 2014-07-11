#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TSBaseDB.h"

@interface TSCoreDataDB : TSBaseDB
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@end
