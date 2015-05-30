#import "TSCoreData.h"
#import <CoreData/CoreData.h>
#import "TSSettings.h"


static NSString * const kDatabaseFailname = @"TSWeatherDatabase";

@interface TSCoreData()

-(NSManagedObject *)searchWeatherRecordInDatabase:(Weather *)weather;
-(NSURL *)applicationDocumentsDirectory;
@end


@implementation TSCoreData

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


//Метод добавляет объект Weather в базу данных
//Если количество записей в базе подошло к ограничительному значению
//в конце будет удалина самая старая запись
-(BOOL)addRecordToDatabase:(Weather *)weather{
    
    //Создаем обект для хранения в базе
    NSManagedObject *weatherToInsert = [NSEntityDescription insertNewObjectForEntityForName:kDatabaseTableName
                                                                     inManagedObjectContext:self.managedObjectContext];
    //наполняем его
    [weatherToInsert setValue:weather.city forKey:kDatabaseKey_City];
    [weatherToInsert setValue:weather.code forKey:kDatabaseKey_Code];
    [weatherToInsert setValue:weather.date forKey:kDatabaseKey_Date];
    [weatherToInsert setValue:weather.temp forKey:kDatabaseKey_Temp];
    [weatherToInsert setValue:weather.text forKey:kDatabaseKey_Text];
    
    //производим сохраниние изменений
    [self saveContext];
    
    //Проверяем появилась ли запись в базе
    if ([self searchWeatherRecordInDatabase:weather]) {
        
        //Если запись попала в БД
        //удаляем старые записи если привышено количество допустимых максимум
        [self removeUnneededRecords];
        return YES;
    }
    //Если запись не появилась
    else{
        
        //генерируем ошибку
        NSString *coreDataError = @"Core Data Error";
        NSString *message = @"Write error";
        NSString *description = @"The record is not added to the database";
        [self generateErrorWithDomain:coreDataError
                         ErrorMessage:message
                          Description:description];
        
        //сообщаем о ошибке
        return NO;
        
    }
}


//метод удаляет объект Weather из базы
//если указанное значение не соответствует ни одной записи из базы
//генерируется ошибка и метод возвращает ложное значение
-(BOOL)deleteRecordFromDatabase:(Weather *)weather{

    //Находим запись в базе
    NSManagedObject *weatherToDelete = [self searchWeatherRecordInDatabase:weather];

    //Если результат не пустой
    if (weatherToDelete) {
        
        //Удаляем элемент
        [self.managedObjectContext deleteObject:weatherToDelete];
        [self saveContext];
        
        //сообщаем что удаление было успешным
        return YES;
    }
    //Если объект был пустым
    else{
        
        //генерируем ошибку
        NSString *coreDataError = @"Core Data Error";
        NSString *message = @"Unable to find the object to remove";
        NSString *description = @"A request for a given object returned an empty result";
        [self generateErrorWithDomain:coreDataError
                         ErrorMessage:message
                          Description:description];
        
        //сообщаем о ошибке
        return NO;
    }
}


//возврашает масив объектов Weather хранящихся в базе данных
-(NSArray *)getArrayOfRecordsFromDatabase{

    //Формируем запрос к базе
    NSEntityDescription *entity = [NSEntityDescription entityForName:kDatabaseTableName
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
     
    //делаем запрос
    NSError *error = nil;
    NSArray *resaltRequest = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    //Если результат не нуливой
    if (resaltRequest != nil) {
        
        //Переписываем результат в массив объектов Weather
        NSMutableArray *weatherArray = [[NSMutableArray alloc] init];
        for (NSManagedObject *extractedObject in resaltRequest) {
            
            Weather *weather = [[Weather alloc] initWithNameOfCity:[extractedObject valueForKeyPath:kDatabaseKey_City]
                                                              code:[extractedObject valueForKeyPath:kDatabaseKey_Code]
                                                              date:[extractedObject valueForKeyPath:kDatabaseKey_Date]
                                                              temp:[extractedObject valueForKeyPath:kDatabaseKey_Temp]
                                                              text:[extractedObject valueForKeyPath:kDatabaseKey_Text]];
            [weatherArray addObject:weather];
        }
        //возвращаем результат
        return weatherArray;
    }
    //Если запрос вернул пустой результат
    else{
        
        //генерируем ошибку
        NSString *coreDataError = @"Core Data Error";
        NSString *message = @"Read error";
        NSString *description = @"The query result was empty";
        [self generateErrorWithDomain:coreDataError
                         ErrorMessage:message
                          Description:description];
        
        //возврашаеи nil
        return nil;
    }
}


//Если количество записей подошло к ограничительному значению метод удалить самую старую запись
//при полнастью заполненой базе после выполнения метода в ней останется столько записей сколько указанно в настройках
-(void)removeUnneededRecords{
    
    //получаем массив объектов из базы
    NSArray *weatherArray = [self getArrayOfRecordsFromDatabase];
    
    //Если записей больше чем нужно
    for (NSInteger index = [[TSSettings sharedController] limitRecordsInDatabase]; index < [weatherArray count]; index++) {
        
        Weather *weatherToDelete = [weatherArray firstObject];
        [self deleteRecordFromDatabase:weatherToDelete];
    }
    
}


//метод ищет указанную (экземпляр класса Weather) запись в базе данных 
-(NSManagedObject *)searchWeatherRecordInDatabase:(Weather *)weather{
    
    //Указываем настройки базы
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entityDesctiption = [NSEntityDescription entityForName: kDatabaseTableName
                                                         inManagedObjectContext:context];
    //Подготавливаем запрос
    //искомый объект должен полностью соответствовать заданному объекту
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(%K = %@ ) and (%K = %@ ) and (%K = %@ ) and (%K = %@ ) and (%K = %@ )",
                              kDatabaseKey_City, weather.city,
                              kDatabaseKey_Code, weather.code,
                              kDatabaseKey_Date, weather.date,
                              kDatabaseKey_Temp, weather.temp,
                              kDatabaseKey_Text, weather.text];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesctiption];
    [request setPredicate:predicate];
    
    //Полуучаем результаты запроса
    NSArray *objectsFromDatabase = [context executeFetchRequest:request error:nil];
    
    //Если результат не пустой
    if ([objectsFromDatabase count] > 0) {
        
        //Возврашаем первый элемент из массива
        return [objectsFromDatabase firstObject];
        
    }
    //Если не найдено ни одной записи вернуть nil
    else{
        
        return nil;
    }
}




#pragma mark - Core Data metods

- (void)saveContext{
    NSError *error = nil;
    _managedObjectContext = self.managedObjectContext;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil){
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}



- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kDatabaseFailname withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TSWeatherDatabase.sqlite"];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:nil]) {
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
