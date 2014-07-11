/*
 Класс работает с обееми (SQLait и CoreData) базами данных автоматически подключаясь к той, 
 которая сейчас указана активной в настройках
 
 поля баз данных
 id (integer) - автоинкрементирующийся счетчик
 city (string) - назнание города
 code (string) - код обозначающий погодные условия в Yahoo Weather (0 tornado, 1 tropical storm, 2 hurricane и т.д)
 date (string) - дата запроса погоды
 temp (integer) - температура
 text (string) - краткое примечание про облачность, осадки и т.д.
*/

#import "TSDB.h"

@implementation TSDB

@synthesize dbError;

//********************************************
//Метод копирует поля из coreData в SQLite после чего очишает исходную базу
-(void) coreDataToSql{
    TSCoreDataDB *coreDataDatabace = [TSCoreDataDB new];
    TSSQLiteDB *sqlDatabase = [TSSQLiteDB new];
    
    //перезапись полей из coreData в SQLite
    for (NSDictionary *dic in coreDataDatabace.linsArray){
        [sqlDatabase addRecordToDatabase:dic];
        
// (!!!) когда исправлю метод кореДата заменить @"id" на символьную константу
        [coreDataDatabace deleteRecordFromDatabase:[dic objectForKey:@"id"]];
    }
}


//********************************************
//Метод копирует поля из SQLite в coreData после чего очишает исходную базу
-(void) sqlToCoreData{
    TSCoreDataDB *coreDataDatabase = [TSCoreDataDB new];
    TSSQLiteDB *sqlDatabase = [TSSQLiteDB new];
    NSArray *sqlDatabase_RecordsArray = [NSArray arrayWithArray:[sqlDatabase getArrayOfRecordsFromDatabase]];
    
    //перезапись полей из SQLite в coreData
    for (NSDictionary *dic in sqlDatabase_RecordsArray){
        [coreDataDatabase addRecordToDatabase:dic];
        [sqlDatabase deleteRecordFromDatabase:[[dic objectForKey:kSqlDatabaseKey_ID] integerValue]];
    }
}

//********************************************
//Метод удалит лишние поля (начиная от самых старых)
//если в базе данных полей больше чем указанно в настройках
-(BOOL) removeUnneededRecords{
    if ([[TSSettings sharedController] DBType]){
        TSCoreDataDB *coreData = [TSCoreDataDB new];
        [coreData removeUnneededRecords];
        return YES;
    }
    else{
        TSSQLiteDB *sqlDatabase = [TSSQLiteDB new];
        if (![sqlDatabase removeUnneededRecords]) {
            dbError = [sqlDatabase sqLiteError];
            return NO;
        }
        return YES;
    }
}

//********************************************
//Метод добавляет новое поле с значениями из NSDictionary
-(BOOL) addRecordToDatabase:(NSDictionary *)dictionary{
    if ([[TSSettings sharedController] DBType]){
        TSCoreDataDB *coreData = [TSCoreDataDB new];
        [coreData addRecordToDatabase:dictionary];
        return YES;
    }
    else{
        TSSQLiteDB *sqlDatabase = [TSSQLiteDB new];
        if(![sqlDatabase addRecordToDatabase:dictionary]){
            dbError = [sqlDatabase sqLiteError];
            return NO;
        }
        return YES;
    }
}


//********************************************
//Метод удаляет поле с указанным id
-(BOOL)deleteRecordFromDatabase:(id)recordID{
    if ([[TSSettings sharedController] DBType]){
        TSCoreDataDB *coreData = [TSCoreDataDB new];
        [coreData deleteRecordFromDatabase:recordID];
        return YES;
    }
    else{
        TSSQLiteDB *sqlDatabase = [TSSQLiteDB new];
        if(![sqlDatabase deleteRecordFromDatabase:[recordID integerValue]]){
            dbError = [sqlDatabase sqLiteError];
            return NO;
        }
        return YES;
    }
}

//********************************************
//Метод обновляет массив записей в базе
-(void)refresh{
    if ([[TSSettings sharedController] DBType]){
        TSCoreDataDB *coreData = [TSCoreDataDB new];
        [coreData refresh];
    }
}

//********************************************
//Метод возвращает из базы данных массив записей (NSDictionary)
-(NSArray *)getArrayOfRecordsFromDatabase{
    if ([[TSSettings sharedController] DBType]){
        TSCoreDataDB *coreData = [TSCoreDataDB new];
        return coreData.linsArray;
    }
    else{
        TSSQLiteDB *sqlDatabase = [TSSQLiteDB new];
        dbError = [sqlDatabase sqLiteError];
        return [sqlDatabase getArrayOfRecordsFromDatabase];
    }
}

@end
