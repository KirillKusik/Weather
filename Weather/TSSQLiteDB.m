/*
 Класс обеспечивает доступ к базе данных SQLite.
 
 Класс специализирует базу ограничивая лишние функции которые не применяются в данном приложении. 
 Также берет на себя формирование SQL запросов.
 
 Для подключения к базе испльзуется оболочка fmdb.
*/

#import "TSSQLiteDB.h"
#import "TSSettings.h"

@implementation TSSQLiteDB

@synthesize sqLiteError;

//********************************************
//метод возврашает масив всех записей (NSDictionary) хранящихся в базе SQLite
-(NSArray *)getArrayOfRecordsFromDatabase{
    //подключаюсь к базе данных
    if (![self databaseConnected]) {
        return nil;
    }
    
    NSString * selectRequest = [NSString stringWithFormat:@"select * from %@",kSqlDatabaseTableName];
    FMResultSet *resalts = [sqLiteDatabase executeQuery:selectRequest];
    NSMutableArray *arrayOfRecords = [NSMutableArray new];
        
    //переписать результат запроса в масив
    while ([resalts next]) {
        NSMutableDictionary *recordFromDatabase = [NSMutableDictionary new];
        [recordFromDatabase setValue:[resalts stringForColumn:kSqlDatabaseKey_ID] forKey:kSqlDatabaseKey_ID];
        [recordFromDatabase setValue:[resalts stringForColumn:kSqlDatabaseKey_City] forKey:kSqlDatabaseKey_City];
        [recordFromDatabase setValue:[resalts stringForColumn:kSqlDatabaseKey_Code] forKey:kSqlDatabaseKey_Code];
        [recordFromDatabase setValue:[resalts stringForColumn:kSqlDatabaseKey_Date] forKey:kSqlDatabaseKey_Date];
        [recordFromDatabase setValue:[resalts stringForColumn:kSqlDatabaseKey_Temp] forKey:kSqlDatabaseKey_Temp];
        [recordFromDatabase setValue:[resalts stringForColumn:kSqlDatabaseKey_Text] forKey:kSqlDatabaseKey_Text];
        [arrayOfRecords addObject:recordFromDatabase];
    }
    [sqLiteDatabase close];
    return arrayOfRecords;
}


//********************************************
//метод удаляет старые записи если их боьше чем указанно в настройках
-(BOOL)removeUnneededRecords{
    NSInteger maxCountOfRecords = [[TSSettings sharedController] limitRecordsInDatabase];
    while ([[self getArrayOfRecordsFromDatabase] count] > maxCountOfRecords){
        NSDictionary * recordFoDeleted = [[self getArrayOfRecordsFromDatabase] objectAtIndex:0];        
        if (![self deleteRecordFromDatabase:[[recordFoDeleted objectForKey:kSqlDatabaseKey_ID] integerValue]]){
            return NO;
        }
    }
    return YES;
}


//********************************************
//метод добавляет запись в SQLite и следит что-бы
//база не содержала лишних записей
-(BOOL)addRecordToDatabase:(NSDictionary *)dictionary{
    //подключаюсь к базе данных
    if (![self databaseConnected]) {
        return NO;
    }
    
    //если подключение произашло без ошибок добавляем в базу новую запись
    NSString *insertRequest = [NSString stringWithFormat:
                             @"insert into %@ ('%@','%@','%@', %@,'%@') values ('%@','%@','%@','%@','%@')",
                             kSqlDatabaseTableName,
                             kSqlDatabaseKey_City,
                             kSqlDatabaseKey_Code,
                             kSqlDatabaseKey_Date,
                             kSqlDatabaseKey_Temp,
                             kSqlDatabaseKey_Text,
                             [dictionary objectForKey:kSqlDatabaseKey_City],
                             [dictionary objectForKey:kSqlDatabaseKey_Code],
                             [dictionary objectForKey:kSqlDatabaseKey_Date],
                             [dictionary objectForKey:kSqlDatabaseKey_Temp],
                             [dictionary objectForKey:kSqlDatabaseKey_Text]];
        
    //проверка выполняется ли запрос
    if (![sqLiteDatabase validateSQL:insertRequest error:nil]) {
        [sqLiteDatabase close];
        NSString *errorDescription = [NSString stringWithFormat:@"request is not valid: %@", insertRequest];
        [self generateErrorWithErrorMessage:@"insert error" andDescription:errorDescription];
        return NO;
    }
        
    [sqLiteDatabase executeUpdate:insertRequest];
    [sqLiteDatabase close];
    
    //если есть удаляем лишние записи
    if (![self removeUnneededRecords]) {
        return NO;
    }
    return YES;
}


//********************************************
//метод удаляет запись из базы по указанному ID
-(BOOL)deleteRecordFromDatabase:(NSUInteger)recordID{
    if (![self databaseConnected]) {
        return NO;
    }
    
    NSString *deleteRequest = [NSString stringWithFormat:@"delete from %@ where %@ = %lu;",kSqlDatabaseTableName, kSqlDatabaseKey_ID, (unsigned long)recordID];
    
    //проверка выполняется ли запрос
    if (![sqLiteDatabase validateSQL:deleteRequest error:nil]) {
        [sqLiteDatabase close];
        NSString *errorDescription = [NSString stringWithFormat:@"request is not valid: %@", deleteRequest];
        [self generateErrorWithErrorMessage:@"delete error" andDescription:errorDescription];
        return NO;
    }
    
    [sqLiteDatabase executeUpdate:deleteRequest];
    [sqLiteDatabase close];
    return YES;
}


//********************************************
//Устанавливает соединение с базой данных. Если соединение успешно вернет YES.
//В противном случае вернет NO и сформирует ошибку.
-(BOOL)databaseConnected{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *dbPath = [documentDir stringByAppendingPathComponent:@"Weather.sqlite"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //если база не сушествует создать ее
    if(![fileManager fileExistsAtPath:dbPath]){
        sqLiteDatabase = [FMDatabase databaseWithPath:dbPath];
        [sqLiteDatabase open];
        NSString * createTableRequest = [NSString stringWithFormat:
                            @"create table %@ (%@ integer primary key, %@ text, %@ text, %@ text, %@ int, %@ text)",
                            kSqlDatabaseTableName,
                            kSqlDatabaseKey_ID,
                            kSqlDatabaseKey_City,
                            kSqlDatabaseKey_Code,
                            kSqlDatabaseKey_Date,
                            kSqlDatabaseKey_Temp,
                            kSqlDatabaseKey_Text];
        
        //проверяем создастся ли таблица
        if (![sqLiteDatabase executeUpdate:createTableRequest]){
            NSString *errorMessage = [NSString stringWithFormat:@"table: %@ not create", kSqlDatabaseTableName];
            NSString *errorDescription = @"database create error";
            [self generateErrorWithErrorMessage:errorMessage andDescription:errorDescription];
            [sqLiteDatabase close];
            return NO;
        }
        [sqLiteDatabase executeUpdate:createTableRequest];
    }
    else{
        //если база сушествовала открываем ее
        sqLiteDatabase = [FMDatabase databaseWithPath:dbPath];
        [sqLiteDatabase open];
    }
    
    //проверяем выполняются ли запросы к базе
    NSString *testRequest = [NSString stringWithFormat:@"select * from %@", kSqlDatabaseTableName];
    if (![sqLiteDatabase validateSQL:testRequest error:nil]){
        NSString *errorMessage = [NSString stringWithFormat:@"error test query"];
        NSString *errorDescription = @"database is not responding";
        [self generateErrorWithErrorMessage:errorMessage andDescription:errorDescription];
        [sqLiteDatabase close];
        return NO;
    }
    return YES;
}


//********************************************
//генерирует ошибку с указанным сообшением и описанием
-(void)generateErrorWithErrorMessage:(NSString *)errorMessage andDescription:(NSString *)description{
    NSString *errorDomain = @"TSSQLite error";
    NSArray *objArray = [NSArray arrayWithObjects:description, errorMessage, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    sqLiteError = [NSError errorWithDomain:errorDomain code:1 userInfo:userInfo];
}

@end
