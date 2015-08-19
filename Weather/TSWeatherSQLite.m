/*
 Класс обеспечивает доступ к базе данных SQLite.
 Для подключения к базе используется оболочка fmdb.
 */

#import "TSWeather.h"
#import "TSWeatherSQLite.h"
#import "TSSettings.h"
#import "FMDB.h"

static NSString * kDatabaseFailname = @"Weather.sqlite";

@interface TSWeatherSQLite(){
    FMDatabase * sqLiteDatabase;
}
@end

@implementation TSWeatherSQLite

//метод добавляет экземпляр класса Weather в базу данных SQLite
//и следит что бы база не содержала лишних записей
-(BOOL)addWeather:(TSWeather *)weather{
    
    //подключаюсь к базе данных, если подключение произашло без ошибок добавляем в базу новую запись
    if ([self databaseConnected]){

        NSString *insertRequest = [NSString stringWithFormat:
                               @"insert into %@ ('%@','%@','%@', %@,'%@') values ('%@','%@','%@','%@','%@')",
                               kDatabaseTableName,
                               kDatabaseKey_City,
                               kDatabaseKey_Code,
                               kDatabaseKey_Date,
                               kDatabaseKey_Temp,
                               kDatabaseKey_Text,
                               weather.city,
                               weather.code,
                               weather.date,
                               weather.temp,
                               weather.text];
    
        //Добавляем запись
        if ([sqLiteDatabase validateSQL:insertRequest error:nil]) {

            [sqLiteDatabase executeUpdate:insertRequest];
            [sqLiteDatabase close];
            return YES;
            
        } else{//Если данные не добавленны генерируем ошибку
        
            [sqLiteDatabase close];
            NSString *sqliteError = @"SQLite Error";
            NSString *message = @"Write error";
            NSString *description = @"Custom error writing data to the database";
            [self generateErrorWithDomain:sqliteError ErrorMessage:message Description:description];
            return NO;
        }
    } else{//Подключения к базе не произашло

        return NO;
    }
}


//метод удаляет указанный объект из базы
-(BOOL)deleteWeather:(TSWeather *)weather{
    
    //Устанавливаем подключение к базе данных
    if ([self databaseConnected]) {
        
        //Получаем номер записи которую нужно удалить
        NSString * selectRequest = [NSString stringWithFormat:
                                    @"SELECT * FROM %@ WHERE %@='%@' and %@='%@' and %@='%@' and %@='%@' and %@='%@'",
                                    kDatabaseTableName,
                                    kDatabaseKey_City, weather.city,
                                    kDatabaseKey_Code, weather.code,
                                    kDatabaseKey_Date, weather.date,
                                    kDatabaseKey_Temp, weather.temp,
                                    kDatabaseKey_Text, weather.text];
        
        FMResultSet *resalts = [sqLiteDatabase executeQuery:selectRequest];
        [resalts next];
        NSString *idToDelete = [resalts stringForColumn:kDatabaseKey_ID];
        
        //Выполняем удаление
        NSString *deleteRequest = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",
                                   kDatabaseTableName,
                                   kDatabaseKey_ID,
                                   idToDelete];

        if ([sqLiteDatabase validateSQL:deleteRequest error:nil]) {

            [sqLiteDatabase executeUpdate:deleteRequest];
            [sqLiteDatabase close];
            return YES;
        } else{//Если запрос не корректен генерируем ошибку
        
            [sqLiteDatabase close];
            NSString *sqliteError = @"SQLite Error";
            NSString *message = @"Deleting error";
            NSString *description = @"The request for removal of records was rejected by base";
            [self generateErrorWithDomain:sqliteError ErrorMessage:message Description:description];
            return NO;
        }
        
    } else{//Если подключение к базе не произошло
        
        return NO;
    }
}


//метод возврашает масив всех записей хранящихся в базе SQLite
-(NSArray *)getWeatherArray{
    
    //подключаюсь к базе данных
    if ([self databaseConnected]) {
        
        NSString * selectRequest = [NSString stringWithFormat:@"select * from %@",kDatabaseTableName];
        FMResultSet *resalts = [sqLiteDatabase executeQuery:selectRequest];
        
        //переписать результат запроса в массив
        NSMutableArray *weatherArray = [NSMutableArray new];
        while ([resalts next]) {

            NSNumber *weatherTemp = [NSNumber numberWithInt:[[resalts stringForColumn:kDatabaseKey_Temp] intValue]];
            TSWeather *weatherRecord = [[TSWeather alloc] initWithNameOfCity:[resalts stringForColumn:kDatabaseKey_City]
                                                                    code:[resalts stringForColumn:kDatabaseKey_Code]
                                                                    date:[resalts stringForColumn:kDatabaseKey_Date]
                                                                    temp:weatherTemp
                                                                    text:[resalts stringForColumn:kDatabaseKey_Text]];
            [weatherArray addObject:weatherRecord];
        }
        
        [sqLiteDatabase close];
        return weatherArray;
        
    } else{//Если подключения не произашло

        return nil;
    }
}


//метод удаляет старые записи если их больше чем указанно в настройках
-(void)setCountRecords:(NSUInteger)count{
    
    //получаем массив объектов из базы
    NSArray *weatherArray = [self getWeatherArray];
    
    //Пока записей больше чем указанно в настройках
    for (NSInteger index = count; index < [weatherArray count]; index++) {
        
        //удалить первую запись в массиве
        TSWeather *weatherToDelete = [weatherArray firstObject];
        [self deleteWeather:weatherToDelete];
    }
}


//Устанавливает соединение с базой данных. Если соединение успешно вернет YES.
//В противном случае вернет NO и сформирует ошибку.
-(BOOL)databaseConnected{
    
    //подключаемся к базе
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentDir stringByAppendingPathComponent:kDatabaseFailname];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //если база сушествовала открываем ее
    if([fileManager fileExistsAtPath:databasePath]){
        
        sqLiteDatabase = [FMDatabase databaseWithPath:databasePath];
        [sqLiteDatabase open];
        
    } else{//если базы не сушествует создать ее

        sqLiteDatabase = [FMDatabase databaseWithPath:databasePath];
        [sqLiteDatabase open];
        NSString * createTableRequest = [NSString stringWithFormat:
                                         @"create table %@ (%@ integer primary key, %@ text, %@ text, %@ text, %@ int, %@ text)",
                                         kDatabaseTableName,
                                         kDatabaseKey_ID,
                                         kDatabaseKey_City,
                                         kDatabaseKey_Code,
                                         kDatabaseKey_Date,
                                         kDatabaseKey_Temp,
                                         kDatabaseKey_Text];
        
        //создаем таблицу
        if ([sqLiteDatabase executeUpdate:createTableRequest]){
            
            [sqLiteDatabase executeUpdate:createTableRequest];
            
        } else{//Если запрос на создание таблицы не выполняется генерируем ошибку

            NSString *sqliteError = @"SQLite Error";
            NSString *errorMessage = [NSString stringWithFormat:@"table: %@ not create", kDatabaseTableName];
            NSString *errorDescription = @"database create error";
            [self generateErrorWithDomain:sqliteError ErrorMessage:errorMessage Description:errorDescription];
            [sqLiteDatabase close];
            return NO;
        }
    }
    
    //проверяем выполняются ли запросы к базе
    if ([sqLiteDatabase validateSQL:[NSString stringWithFormat:@"select * from %@", kDatabaseTableName] error:nil]){
        
        //Все хорошо
        return YES;
    } else{//Если запрос к таблице не произашол генерируем ошибку
        
        NSString *sqliteError = @"SQLite Error";
        NSString *errorMessage = @"error test query";
        NSString *errorDescription = @"database is not responding";
        [self generateErrorWithDomain:sqliteError ErrorMessage:errorMessage Description:errorDescription];
        [sqLiteDatabase close];
        return NO;
    }
}

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
