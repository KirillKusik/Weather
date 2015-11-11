/*
 Класс, является коллекцией данных, хранящий геокод и адреса населенного пункта
 */

#import "TSYahooGeocode.h"

@implementation TSYahooGeocode

-(id)initGeocodeWithContry:(NSString *)country region:(NSString *)region town:(NSString *)town
        geocode:(NSString *)geocode {
    self = [super init];
    if (self) {
        self.country = country;
        self.region = region;
        self.town = town;
        self.geocode = geocode;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"country:%@ region:%@ town:%@ geocode:%@", self.country, self.region, self.town,
            self.geocode];
}
@end
