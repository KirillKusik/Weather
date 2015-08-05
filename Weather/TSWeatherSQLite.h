/*
 Класс обеспечивает доступ к базе данных SQLite.
 Для подключения к базе используется оболочка fmdb.
 */

#import <Foundation/Foundation.h>
#import "TSWeatherDatabasePreform.h"

@interface TSWeatherSQLite : NSObject

@property (nonatomic, readonly) NSError *error;

//метод добавляет экземпляр класса Weather в базу данных SQLite
//и следит что бы база не содержала лишних записей
-(BOOL)addWeather:(TSWeather *)weather;

//метод удаляет указанный объект из базы
-(BOOL)deleteWeather:(TSWeather *)weather;

//метод возвращает массив всех записей хранящихся в базе SQLite
-(NSArray *)getWeatherArray;

//метод удаляет старые записи если их больше чем указанно в настройках
-(void)setCountRecords:(NSUInteger)count;
@end
