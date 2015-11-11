/*
 Класс обеспечивает связь с базой данных Core Data
*/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TSWeatherDatabasePreform.h"

@class TSWeather;

@interface TSWeatherCoreData :NSObject


-(BOOL)addWeather:(TSWeather *)weather;
-(BOOL)deleteWeather:(TSWeather *)weather;
-(NSArray *)getWeatherArray;
-(void)setCountRecords:(NSUInteger)count;
-(NSError *)error;
@end
