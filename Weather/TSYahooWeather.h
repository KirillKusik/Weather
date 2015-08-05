/*
 метод предназначен для загрузки прогноза погоды по заданному городу
 при использовании REST сервиса Yahoo weather
 
 https://developer.yahoo.com/weather/documentation.html
 */

#import <Foundation/Foundation.h>
#import "TSWeather.h"

@interface TSYahooWeather : NSObject
@property (readonly) NSError *error;

//Возвращает массив геокодов населенны пунктов названия которых соответствуют введенному слову
-(NSArray *)getYahooGeocodes:(NSString *)city;

//метод возвращает прогноз погоды (объект Weather) по введенному геокоду
-(TSWeather *)getYahooWeather:(NSString *)geocode;
@end
