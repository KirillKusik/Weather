#import "TSWeatherCoreData.h"
#import <CoreData/CoreData.h>


static NSString * kDatabaseFailname = @"TSWeatherDatabase";

@implementation TSWeatherCoreData

//Метод добавляет объект Weather в базу данных
//Если количество записей в базе подошло к ограничительному значению
//в конце будет удалена самая старая запись
-(BOOL)addWeather:(TSWeather *)weather{
    
    //Создаем объект для хранения в базе
    NSManagedObject *weatherToInsert = [NSEntityDescription insertNewObjectForEntityForName:kDatabaseTableName
                                                                     inManagedObjectContext:self.managedObjectContext];
    [weatherToInsert setValue:weather.city forKey:kDatabaseKey_City];
    [weatherToInsert setValue:weather.code forKey:kDatabaseKey_Code];
    [weatherToInsert setValue:weather.date forKey:kDatabaseKey_Date];
    [weatherToInsert setValue:weather.temp forKey:kDatabaseKey_Temp];
    [weatherToInsert setValue:weather.text forKey:kDatabaseKey_Text];
    [self saveContext];
    
    //Проверяем появилась ли запись в базе
    if ([self searchWeatherRecordInDatabase:weather]) {
        
        return YES;
        
    } else{//Если запись не появилась генерируем ошибку
        
        NSString *coreDataError = @"Core Data Error";
        NSString *message = @"Write error";
        NSString *description = @"The record is not added to the database";
        [self generateErrorWithDomain:coreDataError ErrorMessage:message Description:description];
        return NO;
    }
}


//метод удаляет объект Weather из базы
//если указанное значение не соответствует ни одной записи из базы
//генерируется ошибка и метод возвращает ложное значение
-(BOOL)deleteWeather:(TSWeather *)weather{

    //Находим запись в базе
    NSManagedObject *weatherToDelete = [self searchWeatherRecordInDatabase:weather];

    //Если результат не пустой удаляем элемент
    if (weatherToDelete) {

        [self.managedObjectContext deleteObject:weatherToDelete];
        [self saveContext];
        return YES;
        
    } else{//Если объект был пустым генерируем ошибку
        
        NSString *coreDataError = @"Core Data Error";
        NSString *message = @"Unable to find the object to remove";
        NSString *description = @"A request for a given object returned an empty result";
        [self generateErrorWithDomain:coreDataError
                         ErrorMessage:message
                          Description:description];
        return NO;
    }
}


//возвращает массив объектов Weather хранящихся в базе данных
-(NSArray *)getWeatherArray{

    //делаем запрос
    NSEntityDescription *entity = [NSEntityDescription entityForName:kDatabaseTableName
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSError *errorMessage;
    NSArray *resaltRequest = [_managedObjectContext executeFetchRequest:fetchRequest error:&errorMessage];
    _error = errorMessage;
    
    //Если результат не нулевой переписываем результат в массив объектов Weather
    if (resaltRequest != nil) {
        
        NSMutableArray *weatherArray = [[NSMutableArray alloc] init];
        for (NSManagedObject *extractedObject in resaltRequest) {
            
            TSWeather *weather = [[TSWeather alloc] initWithNameOfCity:[extractedObject valueForKeyPath:kDatabaseKey_City]
                                                              code:[extractedObject valueForKeyPath:kDatabaseKey_Code]
                                                              date:[extractedObject valueForKeyPath:kDatabaseKey_Date]
                                                              temp:[extractedObject valueForKeyPath:kDatabaseKey_Temp]
                                                              text:[extractedObject valueForKeyPath:kDatabaseKey_Text]];
            [weatherArray addObject:weather];
        }
        //возвращаем результат
        return weatherArray;
        
    } else{//Если запрос вернул пустой результат генерируем ошибку
        
        NSString *coreDataError = @"Core Data Error";
        NSString *message = @"Read error";
        NSString *description = @"The query result was empty";
        [self generateErrorWithDomain:coreDataError
                         ErrorMessage:message
                          Description:description];
        return nil;
    }
}


//Если количество записей подошло к ограничительному значению метод удалить самую старую запись
//при полностью заполненной базе после выполнения метода в ней останется столько записей сколько указанно в настройках
-(void)setCountRecords:(NSUInteger)count{
    
    //получаем массив объектов из базы
    NSArray *weatherArray = [self getWeatherArray];
    
    //Если записей больше чем нужно удаляем лишние начиная с самой старой
    for (NSInteger index = count; index < [weatherArray count]; index++) {
        
        TSWeather *weatherToDelete = [weatherArray firstObject];
        [self deleteWeather:weatherToDelete];
    }
}


//метод ищет указанную (экземпляр класса Weather) запись в базе данных 
-(NSManagedObject *)searchWeatherRecordInDatabase:(TSWeather *)weather{
    
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
    NSArray *objectsFromDatabase = [context executeFetchRequest:request error:nil];
    
    //Если результат не пустой возвращаем первый элемент из массива
    if ([objectsFromDatabase count] > 0) {
        
        return [objectsFromDatabase firstObject];
        
    } else{//Если не найдено ни одной записи вернуть nil
        
        return nil;
    }
}


#pragma mark - Core Data metods

- (void)saveContext{
    NSError *errorMessage = nil;
    _managedObjectContext = self.managedObjectContext;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&errorMessage]) {
            NSLog(@"Unresolved error %@, %@", errorMessage, [errorMessage userInfo]);
            _error = errorMessage;
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

#pragma mark - Generate Error metod
//метод генерацыи ошибки
-(void)generateErrorWithDomain:(NSString *)domain
                  ErrorMessage:(NSString *)message
                   Description:(NSString *)description{
    
    NSArray *objArray = [NSArray arrayWithObjects:description, message, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    _error = [NSError errorWithDomain:domain code:1 userInfo:userInfo];
}

@end
