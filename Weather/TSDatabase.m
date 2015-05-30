/*
 Класс работает с обееми (SQLait и CoreData) базами данных автоматически подключаясь к той, 
 которая сейчас указана активной в настройках
*/

#import "TSDatabase.h"
#import "TSSettings.h"
#import "TSSQLite.h"
#import "TSCoreData.h"

@implementation TSDatabase

@synthesize error;

//Метод добавляет значения (класс Weather) в базу данных
//которая на данный момен указанна в настройках как активная
//Если запись не произошла па какойто причине метод возвращает NO
//и генерирует в даных класса error
-(BOOL) addRecordToDatabase:(Weather *)weather{
    
    //Если в настройках указан тип базы CoreData
    if ([[TSSettings sharedController] DBType] == CoreDataDatabaseType){
        
        //добавляем запись в базу CoreData
        TSCoreData *coreData = [[TSCoreData alloc] init];
        if ([coreData addRecordToDatabase:weather]){
            
            return YES;
        }
        //Если CoreData не добавить запись
        else{
            
            //Добавление не вполненно
            error = coreData.error;
            return NO;
        }
    }
    //Если в настройках указан тип базы данных SQLite
    else if ([[TSSettings sharedController] DBType] == SQLiteDatabaseType){
        
        //добовляем запись в базу SQLite
        TSSQLite *sqLite = [[TSSQLite alloc] init];
        if ([sqLite addRecordToDatabase:weather]) {
            
            return YES;
        }
        //Если SQLite не добавил запись
        else{
            
            //Добавление не выполненно
            error = sqLite.error;
            return NO;
        }
    }
    //Если указан другой тип базы
    else{
        
        //Сгенерировать ощибку
        [self generateDatabaseTypeError];
        return NO;
    }
}


//Метод удаляет значения (класс Weather) из базы данных
//которая на данный момен указанна в настройках как активная
//Если удаление не произошло па какойто причине метод возвращает NO
//и генерирует в даных класса error
-(BOOL)deleteRecordFromDatabase:(Weather *)weather{
    
    //Если в настройках указан тип базы CoreData
    if ([[TSSettings sharedController] DBType] == CoreDataDatabaseType){
        
        //Удаляем запись из базы CoreData
        TSCoreData *coreData = [[TSCoreData alloc] init];
        if ([coreData deleteRecordFromDatabase:weather]){
            
            return YES;
        }
        //Если CoreData не удалил запись
        else{
            
            //Удаление не вполненно
            error = coreData.error;
            return NO;
        }
    }
    //Если в настройках указан тип базы данных SQLite
    else if ([[TSSettings sharedController] DBType] == SQLiteDatabaseType){
        
        //Удаляем запись из базы SQLite
        TSSQLite *sqLite = [[TSSQLite alloc] init];
        if ([sqLite deleteRecordFromDatabase:weather]) {
            
            return YES;
        }
        //Если SQLite не удалил запись
        else{
            
            //Удаление не выполненно
            error = sqLite.error;
            return NO;
        }
    }
    //Если указан другой тип базы
    else{
        
        //Сгенерировать ощибку
        [self generateDatabaseTypeError];
        return NO;
    }
}


//Возврашает массив объектов типа Weather из активной на данный момент базы
-(NSArray *)getArrayOfRecordsFromDatabase{

    //Если в настройках указан тип базы CoreData
    if ([[TSSettings sharedController] DBType] == CoreDataDatabaseType){
        
        //Получаем содержимое базы CoreData
        TSCoreData *coreData = [[TSCoreData alloc] init];
        NSArray *weatherArray = [coreData getArrayOfRecordsFromDatabase];
        
        if ([weatherArray count] > 0){
            
            return weatherArray;
        }
        //Если массив пуст
        else{
            
            error = coreData.error;
            return nil;
        }
    }
    //Если в настройках указан тип базы данных SQLite
    else if ([[TSSettings sharedController] DBType] == SQLiteDatabaseType){
        
        //Получаем содержимое базы SQLite
        TSSQLite *sqLite = [[TSSQLite alloc] init];
        NSArray *weatherArray = [sqLite getArrayOfRecordsFromDatabase];
        
        if ([weatherArray count] > 0) {
            
            return weatherArray;
        }
        //Если массив пуст
        else{
            
            error = sqLite.error;
            return NO;
        }
    }
    //Если указан другой тип базы
    else{
        
        //Сгенерировать ощибку
        [self generateDatabaseTypeError];
        return NO;
    }
}



//Метод удалит лишние поля (начиная от самых старых)
//если в базе данных полей больше чем указанно в настройках
-(void)removeUnneededRecords{
    
    //Если в настройках указан тип базы CoreData
    if ([[TSSettings sharedController] DBType] == CoreDataDatabaseType){
        
        //Удалить лишние записи из базы CoreData
        TSCoreData *coreData = [[TSCoreData alloc] init];
        [coreData removeUnneededRecords];
        
    }
    //Если в настройках указан тип базы данных SQLite
    else if ([[TSSettings sharedController] DBType] == SQLiteDatabaseType){
        
        //Удалить лишние записи из базы SQLite
        TSSQLite *sqLite = [[TSSQLite alloc] init];
        [sqLite removeUnneededRecords];
    }
    //Если указан другой тип базы
    else{
        
        //Сгенерировать ощибку
        [self generateDatabaseTypeError];
    }
}

//Метод копирует поля из coreData в SQLite после чего очишает исходную базу
-(void)coreDataToSql{
    
    //Если SQLite в данный момент активна
    if ([[TSSettings sharedController] DBType] == SQLiteDatabaseType){
        
        //Получаем массив значений из CoreData
        TSCoreData *coreData = [[TSCoreData alloc] init];
        NSArray *weatherArray = [coreData getArrayOfRecordsFromDatabase];
        
        //перезапись полей из coreData в SQLite
        //это же значение из CoreData удаляется
        TSSQLite *sqLite = [[TSSQLite alloc] init];
        for (Weather *weather in weatherArray){
            
            [sqLite addRecordToDatabase:weather];
            [coreData deleteRecordFromDatabase:weather];
        }
    }
}



//Метод копирует поля из SQLite в coreData после чего очишает исходную базу
-(void)sqlToCoreData{
    
    //Если CoreData в данный момент активна
    if ([[TSSettings sharedController] DBType] == CoreDataDatabaseType){
        
        //Получаем массив значений из
        TSSQLite *sqLite = [[TSSQLite alloc] init];
        NSArray *weatherArray = [sqLite getArrayOfRecordsFromDatabase];
    
        //перезапись полей из SQLite в coreData
        //это же значение из SQLite удаляется
        TSCoreData *coreData = [[TSCoreData alloc] init];
        for (Weather *weather in weatherArray){
            
            [coreData addRecordToDatabase:weather];
            [sqLite deleteRecordFromDatabase:weather];
        }
    }
}

//Метод генерирует ошибку для случаев когда указан неизвесный тип базы банных
-(void)generateDatabaseTypeError{
    
    NSString *databaseError = @"Database Error";
    NSString *errorMessage = @"Database type error";
    NSString *errorDescription = @"Unknown type of database";
    
    [self generateErrorWithDomain:databaseError
                     ErrorMessage:errorMessage
                      Description:errorDescription];
}


@end
