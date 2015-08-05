/*
 Класс, является коллекцией данных, хранящий геокод и адреса населенного пункта
 */

#import "TSYahooGeocode.h"

@implementation TSYahooGeocode

-(id)initGeocodeWithContry:(NSString *)country
                    region:(NSString *)region
                      town:(NSString *)town
                   geocode:(NSString *)geocode{
    
    self = [super init];
    if (self) {
        _country = country;
        _region = region;
        _town = town;
        _geocode = geocode;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"country:%@ region:%@ town:%@ geocode:%@", _country, _region, _town, _geocode];
}
@end
