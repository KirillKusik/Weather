/*
 Класс работает с обеими (SQLait и CoreData) базами данных автоматически подключаясь к той,
 которая сейчас указана активной в настройках
*/

#import "TSWeather.h"
#import "TSWeatherDatabase.h"
#import "TSWeatherSQLite.h"
#import "TSWeatherCoreData.h"


@implementation TSWeatherDatabase

-(instancetype)initWithSettings:(TSSettings *)settings{
    
    self = [super init];
    if (self) {
        
        databaseType = settings.databaseType;
        databaseCount = settings.databaseCount;
    }
    
    return self;
}


//Метод добавляет значения (класс Weather) в базу данных
//которая на данный момент указанна в настройках как активная
//Если запись не произошла па какой-то причине метод возвращает NO
//и генерирует в данных класса error
-(BOOL) addWeather:(TSWeather *)weather{
    
    //Если в настройках указан тип базы CoreData
    if (databaseType == CoreDataDatabaseType){
        
        //добавляем запись в базу CoreData
        TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
        if ([coreData addWeather:weather]){
            
            [coreData setCountRecords:databaseCount];
            return YES;
        } else{//Если CoreData не добавить запись
            
            _error = coreData.error;
            return NO;
        }
    }//Если в настройках указан тип базы данных SQLite
    else if (databaseType == SQLiteDatabaseType){
        
        //добавляем запись в базу SQLite
        TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
        if ([sqLite addWeather:weather]) {
            
            [sqLite setCountRecords:databaseCount];
            return YES;
        } else{//Если SQLite не добавил запись

            _error = sqLite.error;
            return NO;
        }
    } else{//Если указан другой тип базы сгенерировать ошибку

        [self generateDatabaseTypeError];
        return NO;
    }
}


//Метод удаляет значения (класс Weather) из базы данных
//которая на данный момент указанна в настройках как активная
//Если удаление не произошло па какой-то причине метод возвращает NO
//и генерирует в данных класса error
-(BOOL)deleteWeather:(TSWeather *)weather{
    
    //Если в настройках указан тип базы CoreData
    if (databaseType == CoreDataDatabaseType){
        
        //Удаляем запись из базы CoreData
        TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
        if ([coreData deleteWeather:weather]){
            
            return YES;
        } else{//Если CoreData не удалил запись

            _error = coreData.error;
            return NO;
        }
    }//Если в настройках указан тип базы данных SQLite
    else if (databaseType == SQLiteDatabaseType){
        
        //Удаляем запись из базы SQLite
        TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
        if ([sqLite deleteWeather:weather]) {
            
            return YES;
        } else{//Если SQLite не удалил запись

            _error = sqLite.error;
            return NO;
        }
    } else{//Если указан другой тип базы сгенерировать ошибку
        
        [self generateDatabaseTypeError];
        return NO;
    }
}


//Возвращает массив объектов типа Weather из активной на данный момент базы
-(NSArray *)getAllWeathers{

    //Если в настройках указан тип базы CoreData
    if (databaseType == CoreDataDatabaseType){
        
        //Получаем содержимое базы CoreData
        TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
        NSArray *weatherArray = [coreData getWeatherArray];
        
        if ([weatherArray count] > 0){
            
            return weatherArray;
        } else{//Если массив пуст

            _error = coreData.error;
            return nil;
        }
    }
    //Если в настройках указан тип базы данных SQLite
    else if (databaseType == SQLiteDatabaseType){
        
        //Получаем содержимое базы SQLite
        TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
        NSArray *weatherArray = [sqLite getWeatherArray];
        
        if ([weatherArray count] > 0) {
            
            return weatherArray;
            
        } else{//Если массив пуст
            
            _error = sqLite.error;
            return nil;
        }
    } else{//Если указан другой тип базы сгенерировать ошибку
        
        [self generateDatabaseTypeError];
        return nil;
    }
}


//Метод удалит лишние поля (начиная от самых старых)
//если в базе данных полей больше чем указанно в настройках
-(void)removeSurplusRecords{
    
    //Если в настройках указан тип базы CoreData
    if (databaseType == CoreDataDatabaseType){
        
        //Удалить лишние записи из базы CoreData
        TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
        [coreData setCountRecords:databaseCount];
        
    }
    //Если в настройках указан тип базы данных SQLite
    else if (databaseType == SQLiteDatabaseType){
        
        //Удалить лишние записи из базы SQLite
        TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
        [sqLite setCountRecords:databaseCount];
        
    } else{//Если указан другой тип базы сгенерировать ошибку
        
        [self generateDatabaseTypeError];
    }
}


//Метод копирует поля из coreData в SQLite после чего очищает исходную базу
-(void)coreDataToSql{
    
    //Если SQLite в данный момент активна
    if (databaseType == SQLiteDatabaseType){
        
        //Получаем массив значений из CoreData
        TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
        NSArray *weatherArray = [coreData getWeatherArray];
        
        //перезапись полей из coreData в SQLite
        TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
        for (TSWeather *weather in weatherArray){
            
            [sqLite addWeather:weather];
            [coreData deleteWeather:weather];
        }
    }
}


//Метод копирует поля из SQLite в coreData после чего очищает исходную базу
-(void)sqlToCoreData{
    
    //Если CoreData в данный момент активна
    if (databaseType == CoreDataDatabaseType){
        
        //Получаем массив значений из SQLite
        TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
        NSArray *weatherArray = [sqLite getWeatherArray];
    
        //перезапись полей из SQLite в coreData
        //это же значение из SQLite удаляется
        TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
        for (TSWeather *weather in weatherArray){
            
            [coreData addWeather:weather];
            [sqLite deleteWeather:weather];
        }
    }
}

//Метод генерирует ошибку для случаев когда указан неизвестный тип базы банных
-(void)generateDatabaseTypeError{
    
    NSString *databaseError = @"Database Error";
    NSString *errorMessage = @"Database type error";
    NSString *errorDescription = @"Unknown type of database";
    
    [self generateErrorWithDomain:databaseError
                     ErrorMessage:errorMessage
                      Description:errorDescription];
}

//метод генерации ошибки
-(void)generateErrorWithDomain:(NSString *)domain
                  ErrorMessage:(NSString *)message
                   Description:(NSString *)description{
    
    NSArray *objArray = [NSArray arrayWithObjects:description, message, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    _error = [NSError errorWithDomain:domain code:1 userInfo:userInfo];
}
@end
