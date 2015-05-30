/*
 Класс, является коллекцией данных, хранящий погоду в конкретном населенном пункте
 city - название города
 code - код обозначающий погодные условия (облачность, туман, снег и тд)
 date - дата запроса
 temp - температура воздуха
 text - дополнительный комментарий по погодным условиям
 */

#import "Weather.h"

@implementation Weather

//Инициализация объекта Weather с параметрами
-(id)initWithNameOfCity:(NSString *)city
                     code:(NSString *)code
                     date:(NSString *)date
                     temp:(NSNumber *)temp
                     text:(NSString *)text{
    
    self = [super init];
    if (self) {
        _city = city;
        _code = code;
        _date = date;
        _temp = temp;
        _text = text;
    }
    return  self;
}

-(void)print{
    
    NSLog(@"city - %@",[self city]);
    NSLog(@"code - %@",[self code]);
    NSLog(@"data - %@",[self date]);
    NSLog(@"temp - %@",[self temp]);
    NSLog(@"text - %@",[self text]);
}
@end
