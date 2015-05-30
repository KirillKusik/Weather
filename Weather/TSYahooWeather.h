/*
 метод предназначен для загрузки прогноза погоды по заданному городу
 при использовании REST сервиса Yahoo weather
 
 https://developer.yahoo.com/weather/documentation.html
 */

#import <Foundation/Foundation.h>
#import "TSDatabase.h"


static NSString * const kWoeidKey_country = @"country";
static NSString * const kWoeidKey_region = @"region";
static NSString * const kWoeidKey_town = @"town";
static NSString * const kWoeidKey_woeid = @"woeid";

@interface TSYahooWeather : NSObject
@property (nonatomic, readonly) NSError *error;

//Возвращает массив с прогнозом погоды в населенны пунктах
//с названиями соответствующими введенному слову
//также проверяет и подготавливает вводимое значение
-(NSArray *)getWoeidArray:(NSString *)city;

//метод возвращает прогноз погоды (объект Weather) по введенному гео-коду
-(Weather *)getWeather:(NSString *)woeid;
@end
