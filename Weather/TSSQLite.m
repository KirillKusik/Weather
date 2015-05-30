/*
 Класс обеспечивает доступ к базе данных SQLite.
 
 Класс специализирует базу ограничивая лишние функции которые не применяются в данном приложении. 
 Также берет на себя формирование SQL запросов.
 
 Для подключения к базе испльзуется оболочка fmdb.
*/

#import "TSSQLite.h"
#import "TSSettings.h"
#import "FMDB.h"

static NSString * const kDatabaseFailname = @"Weather.sqlite";

@interface TSSQLite(){
    FMDatabase * sqLiteDatabase;
}

-(BOOL)databaseConnected;
@end

@implementation TSSQLite
@synthesize error;


//метод добавляет экземпляр класса Weather в базу данных SQLite
//и следит что-бы база не содержала лишних записей
-(BOOL)addRecordToDatabase:(Weather *)weather{
    
    //подключаюсь к базе данных
    if ([self databaseConnected]){
    
        //если подключение произашло без ошибок добавляем в базу новую запись
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
    
        //проверка выполняется ли запрос
        if ([sqLiteDatabase validateSQL:insertRequest error:nil]) {
            
            //Добавляем запись
            [sqLiteDatabase executeUpdate:insertRequest];
            [sqLiteDatabase close];
            
            //если есть удаляем лишние записи
            [self removeUnneededRecords];
            
            return YES;
        }
        //Если данные не добавленны
        else{
            
            [sqLiteDatabase close];
            
            //генерируем ошибку
            NSString *sqliteError = @"SQLite Error";
            NSString *message = @"Write error";
            NSString *description = @"Custom error writing data to the database";
            
            [self generateErrorWithDomain:sqliteError
                             ErrorMessage:message
                              Description:description];
            
            //сообщаем о ошибке
            return NO;
        }
    }
    //Подключения к базе не произашло
    else{
        return NO;
    }
}



//метод удаляет указанный объект из базы
-(BOOL)deleteRecordFromDatabase:(Weather *)weather{
    
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
        
        //Составляем запрос на удаление записи
        NSString *deleteRequest = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",
                                   kDatabaseTableName,
                                   kDatabaseKey_ID,
                                   idToDelete];

        //проверка выполняется ли запрос
        if ([sqLiteDatabase validateSQL:deleteRequest error:nil]) {
            
            //Выполняем удаление
            [sqLiteDatabase executeUpdate:deleteRequest];
            [sqLiteDatabase close];
            return YES;
        }
        //Если запрос не корректен
        else{
            
            [sqLiteDatabase close];
            
            //генерируем ошибку
            NSString *sqliteError = @"SQLite Error";
            NSString *message = @"Deleting error";
            NSString *description = @"The request for removal of records was rejected by base";
            
            [self generateErrorWithDomain:sqliteError
                             ErrorMessage:message
                              Description:description];
            return NO;
        }
        
    }
    //Если подключение к базе не произошло
    else{
        return NO;
    }
}



//метод возврашает масив всех записей (NSDictionary) хранящихся в базе SQLite
-(NSArray *)getArrayOfRecordsFromDatabase{
    
    //подключаюсь к базе данных
    if ([self databaseConnected]) {
        
        NSString * selectRequest = [NSString stringWithFormat:@"select * from %@",kDatabaseTableName];
        FMResultSet *resalts = [sqLiteDatabase executeQuery:selectRequest];
        
        //переписать результат запроса в масив
        NSMutableArray *weatherArray = [NSMutableArray new];
        while ([resalts next]) {

            NSNumber *weatherTemp = [NSNumber numberWithInt:[[resalts stringForColumn:kDatabaseKey_Temp] intValue]];
            Weather *weatherRecord = [[Weather alloc] initWithNameOfCity:[resalts stringForColumn:kDatabaseKey_City]
                                                                    code:[resalts stringForColumn:kDatabaseKey_Code]
                                                                    date:[resalts stringForColumn:kDatabaseKey_Date]
                                                                    temp:weatherTemp
                                                                    text:[resalts stringForColumn:kDatabaseKey_Text]];
            
            [weatherArray addObject:weatherRecord];
        }
        
        [sqLiteDatabase close];
        return weatherArray;
    }
    //Если подключения не произашло
    else{
        return nil;
    }
}



//метод удаляет старые записи если их боьше чем указанно в настройках
-(void)removeUnneededRecords{
    
    //получаем массив объектов из базы
    NSArray *weatherArray = [self getArrayOfRecordsFromDatabase];
    
    //Пока записей не снанет не больше чем указанно в настройках
    for (NSInteger index = [[TSSettings sharedController] limitRecordsInDatabase]; index < [weatherArray count]; index++) {
        
        //удалить первую запись в массиве
        Weather *weatherToDelete = [weatherArray firstObject];
        [self deleteRecordFromDatabase:weatherToDelete];
    }
}



//Устанавливает соединение с базой данных. Если соединение успешно вернет YES.
//В противном случае вернет NO и сформирует ошибку.
-(BOOL)databaseConnected{
    
    //Подготавливаем подключение к базе
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentDir stringByAppendingPathComponent:kDatabaseFailname];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //если база сушествовала
    if([fileManager fileExistsAtPath:databasePath]){
        
        //открываем ее
        sqLiteDatabase = [FMDatabase databaseWithPath:databasePath];
        [sqLiteDatabase open];
    }
    //если базы не сушествует
    else{
        
        //создать ее
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
        
        //проверяем создастся ли таблица
        if ([sqLiteDatabase executeUpdate:createTableRequest]){
            
            //создаем таблицу
            [sqLiteDatabase executeUpdate:createTableRequest];
        }
        //Если запрос на создание таблицы не выполняется
        else{
            
            //генерируем ошибку
            NSString *sqliteError = @"SQLite Error";
            NSString *errorMessage = [NSString stringWithFormat:@"table: %@ not create", kDatabaseTableName];
            NSString *errorDescription = @"database create error";
            [self generateErrorWithDomain:sqliteError
                             ErrorMessage:errorMessage
                              Description:errorDescription];
            [sqLiteDatabase close];
            return NO;
        }
    }
    
    //проверяем выполняются ли запросы к базе
    if ([sqLiteDatabase validateSQL:[NSString stringWithFormat:@"select * from %@", kDatabaseTableName] error:nil]){
        
        //Все хорошо
        return YES;
    }
    //Если запрос к таблице произашол с ошибкой
    else{
        
        //генерируем ошибку
        NSString *sqliteError = @"SQLite Error";
        NSString *errorMessage = @"error test query";
        NSString *errorDescription = @"database is not responding";
        
        [self generateErrorWithDomain:sqliteError
                         ErrorMessage:errorMessage
                          Description:errorDescription];
        
        [sqLiteDatabase close];
        return NO;
    }
}

@end
