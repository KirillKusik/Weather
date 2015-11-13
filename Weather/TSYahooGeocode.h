/*
 Класс, является коллекцией данных, хранящий геокод и адреса населенного пункта
 */

#import <Foundation/Foundation.h>

@interface TSYahooGeocode : NSObject


-(id)initGeocodeWithContry:(NSString *)country region:(NSString *)region town:(NSString *)town
        geocode:(NSString *)geocode;
-(NSString *)country;
-(NSString *)region;
-(NSString *)town;
-(NSString *)geocode;

@end
