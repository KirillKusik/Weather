/*
 Класс работает с обеими (SQLait и CoreData) базами данных автоматически подключаясь к той,
 которая сейчас указана активной в настройках
 */

#import <Foundation/Foundation.h>
#import "TSWeatherDatabasePreform.h"

typedef enum {
    CoreDataDatabaseType,
    SQLiteDatabaseType
} DatabaseType;

@class TSWeather;

@interface TSWeatherDatabase : NSObject


+(instancetype)sharedDatabase;
-(void)migrateToDatabase:(DatabaseType)databaseType;
-(void)setMaxRecordsValueInDatabase:(NSUInteger)maxRecordsValue;
-(DatabaseType)databaseType;
-(NSUInteger)maxRecordsValueInDatabase;
-(NSUInteger)recordsCount;
-(BOOL)addWeather:(TSWeather *)weather;
-(BOOL)deleteWeather:(TSWeather *)weather;
-(NSArray *)getAllWeathers;
-(NSError *)error;
@end
