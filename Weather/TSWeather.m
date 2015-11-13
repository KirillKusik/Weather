/*
 Класс, является коллекцией данных, хранящий погоду в конкретном населенном пункте
 city - название города
 code - код обозначающий погодные условия (облачность, туман, снег и тд)
 date - дата запроса
 temp - температура воздуха
 text - дополнительный комментарий по погодным условиям
 */

#import "TSWeather.h"

@interface TSWeather ()
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *code;
@property (nonatomic) NSString *date;
@property (nonatomic) NSNumber *temp;
@property (nonatomic) NSString *text;
@end

@implementation TSWeather

-(id)initWithNameOfCity:(NSString *)city code:(NSString *)code date:(NSString *)date temp:(NSNumber *)temp
        text:(NSString *)text {
    self = [super init];
    if (self) {
        self.city = city;
        self.code = code;
        self.date = date;
        self.temp = temp;
        self.text = text;
    }
    return  self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"city-%@ code-%@ data-%@ temp-%@ text-%@", self.city, self.code, self.date,
            self.temp, self.text];
}

@end
