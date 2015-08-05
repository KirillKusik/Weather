/*
 Класс, является коллекцией данных, хранящий геокод и адреса населенного пункта
 */

#import <Foundation/Foundation.h>

@interface TSYahooGeocode : NSObject
@property (nonatomic, readonly) NSString *country;
@property (nonatomic, readonly) NSString *region;
@property (nonatomic, readonly) NSString *town;
@property (nonatomic, readonly) NSString *geocode;

-(id)initGeocodeWithContry:(NSString *)country
                    region:(NSString *)region
                      town:(NSString *)town
                   geocode:(NSString *)geocode;
@end
