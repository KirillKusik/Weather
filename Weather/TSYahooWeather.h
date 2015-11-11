/*
 метод предназначен для загрузки прогноза погоды по заданному городу
 при использовании REST сервиса Yahoo weather
 
 https://developer.yahoo.com/weather/documentation.html
 */

#import <Foundation/Foundation.h>
#import "TSWeather.h"

@protocol TSYahooWeatherProtocol <NSObject>
-(void)TakeYahooGeocodeArray:(NSArray *)geocodeArray error:(NSError *)error;
-(void)TakeYahooWeather:(TSWeather *)weather error:(NSError *)error;
@end

@interface TSYahooWeather : NSObject
-(instancetype)initWithDelegate:(id)delegate;
-(void)getYahooGeocodes:(NSString *)city;
-(void)getYahooWeather:(NSString *)geocode;
@end
