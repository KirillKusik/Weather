/*
 Класс обеспечивает доступ к базе данных SQLite.
 Для подключения к базе используется оболочка fmdb.
 */

#import <Foundation/Foundation.h>
#import "TSWeatherDatabasePreform.h"

@class TSWeather;

@interface TSWeatherSQLite : NSObject

-(BOOL)addWeather:(TSWeather *)weather;
-(BOOL)deleteWeather:(TSWeather *)weather;
-(NSArray *)getWeatherArray;
-(void)setCountRecords:(NSUInteger)count;
-(NSError *)error;
@end
