/*
 Класс обеспечивает доступ к базе данных SQLite.
 Для подключения к базе используется оболочка fmdb.
 */

#import "TSWeather.h"
#import "TSWeatherSQLite.h"
#import "FMDB.h"

static NSString *kDatabaseFailname = @"Weather.sqlite";

@interface TSWeatherSQLite()
@property (nonatomic) FMDatabase *sqLiteDatabase;
@property (nonatomic) NSError *error;
@end

@implementation TSWeatherSQLite

#pragma mark - Methods of adding, deleting, and getting the content database
-(BOOL)addWeather:(TSWeather *)weather {
    if ([self databaseConnected]){
        NSString *insertRequest = [NSString stringWithFormat:
                @"insert into %@ ('%@','%@','%@', %@,'%@') values ('%@','%@','%@','%@','%@')",kDatabaseTableName,
                kDatabaseKey_City,kDatabaseKey_Code, kDatabaseKey_Date, kDatabaseKey_Temp, kDatabaseKey_Text,
                weather.city, weather.code, weather.date, weather.temp, weather.text];
        if ([self.sqLiteDatabase validateSQL:insertRequest error:nil]) {
            [self.sqLiteDatabase executeUpdate:insertRequest];
            [self.sqLiteDatabase close];
            return YES;
        } else {
            [self.sqLiteDatabase close];
            [self generateErrorWithDomain:@"SQLite Error" ErrorMessage:@"Write error"
                        Description:@"Custom error writing data to the database"];
            return NO;
        }
    } else {
        return NO;
    }
}

-(BOOL)deleteWeather:(TSWeather *)weather {
    if ([self databaseConnected]) {
        NSString * selectRequest = [NSString stringWithFormat:
                @"SELECT * FROM %@ WHERE %@='%@' and %@='%@' and %@='%@' and %@='%@' and %@='%@'", kDatabaseTableName,
                kDatabaseKey_City, weather.city, kDatabaseKey_Code, weather.code, kDatabaseKey_Date, weather.date,
                kDatabaseKey_Temp, weather.temp, kDatabaseKey_Text, weather.text];
        FMResultSet *resalts = [self.sqLiteDatabase executeQuery:selectRequest];
        [resalts next];
        NSString *idToDelete = [resalts stringForColumn:kDatabaseKey_ID];
        NSString *deleteRequest = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'", kDatabaseTableName,
                kDatabaseKey_ID, idToDelete];
        if ([self.sqLiteDatabase validateSQL:deleteRequest error:nil]) {
            [self.sqLiteDatabase executeUpdate:deleteRequest];
            [self.sqLiteDatabase close];
            return YES;
        } else {
            [self.sqLiteDatabase close];
            [self generateErrorWithDomain:@"SQLite Error" ErrorMessage:@"Deleting error"
                        Description:@"The request for removal of records was rejected by base"];
            return NO;
        }
    } else {
        return NO;
    }
}

-(NSArray *)getWeatherArray {
    if ([self databaseConnected]) {
        NSString * selectRequest = [NSString stringWithFormat:@"select * from %@",kDatabaseTableName];
        FMResultSet *resalts = [self.sqLiteDatabase executeQuery:selectRequest];
        NSMutableArray *weatherArray = [NSMutableArray new];
        while ([resalts next]) {
            NSNumber *weatherTemp = [NSNumber numberWithInt:[[resalts stringForColumn:kDatabaseKey_Temp] intValue]];
            TSWeather *weatherRecord = [[TSWeather alloc] initWithNameOfCity:[resalts stringForColumn:kDatabaseKey_City]
                    code:[resalts stringForColumn:kDatabaseKey_Code] date:[resalts stringForColumn:kDatabaseKey_Date]
                    temp:weatherTemp text:[resalts stringForColumn:kDatabaseKey_Text]];
            [weatherArray addObject:weatherRecord];
        }
        [self.sqLiteDatabase close];
        return weatherArray;
    } else {
        return nil;
    }
}

#pragma mark - Change database settings
-(void)setCountRecords:(NSUInteger)count {
    NSArray *weatherArray = [self getWeatherArray];
    if (count < [weatherArray count]) {
        for (NSUInteger index = 0; index < ([weatherArray count] - count); index++) {
            TSWeather *weatherToDelete = [weatherArray objectAtIndex:index];
            [self deleteWeather:weatherToDelete];
        }
    }
}

#pragma mark - SQLite metods
-(BOOL)databaseConnected {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentDir stringByAppendingPathComponent:kDatabaseFailname];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:databasePath]) {
        self.sqLiteDatabase = [FMDatabase databaseWithPath:databasePath];
        [self.sqLiteDatabase open];
    } else {
        self.sqLiteDatabase = [FMDatabase databaseWithPath:databasePath];
        [self.sqLiteDatabase open];
        NSString * createTableRequest = [NSString stringWithFormat:
                @"create table %@ (%@ integer primary key, %@ text, %@ text, %@ text, %@ int, %@ text)",
                kDatabaseTableName, kDatabaseKey_ID, kDatabaseKey_City, kDatabaseKey_Code, kDatabaseKey_Date,
                kDatabaseKey_Temp, kDatabaseKey_Text];
        if ([self.sqLiteDatabase executeUpdate:createTableRequest]) {
            [self.sqLiteDatabase executeUpdate:createTableRequest];
        } else {
            NSString *sqliteError = @"SQLite Error";
            NSString *errorMessage = [NSString stringWithFormat:@"table: %@ not create", kDatabaseTableName];
            NSString *errorDescription = @"database create error";
            [self generateErrorWithDomain:sqliteError ErrorMessage:errorMessage Description:errorDescription];
            [self.sqLiteDatabase close];
            return NO;
        }
    }
    if ([self.sqLiteDatabase validateSQL:[NSString stringWithFormat:@"select * from %@", kDatabaseTableName] error:nil]) {
        return YES;
    } else {
        [self generateErrorWithDomain:@"SQLite Error" ErrorMessage:@"error test query"
                Description:@"database is not responding"];
        [self.sqLiteDatabase close];
        return NO;
    }
}

#pragma mark - Error metod
-(void)generateErrorWithDomain:(NSString *)domain ErrorMessage:(NSString *)message Description:(NSString *)description {
    NSArray *objArray = [NSArray arrayWithObjects:description, message, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    self.error = [NSError errorWithDomain:domain code:1 userInfo:userInfo];
}
@end
