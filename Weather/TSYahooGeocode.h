/*
 Класс, является коллекцией данных, хранящий геокод и адреса населенного пункта
 */

#import <Foundation/Foundation.h>

@interface TSYahooGeocode : NSObject
@property (nonatomic) NSString *country;
@property (nonatomic) NSString *region;
@property (nonatomic) NSString *town;
@property (nonatomic) NSString *geocode;

-(id)initGeocodeWithContry:(NSString *)country region:(NSString *)region town:(NSString *)town
        geocode:(NSString *)geocode;
@end
