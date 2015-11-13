/*
 Класс, является коллекцией данных, хранящий погоду в конкретном населенном пункте
 city - название города
 code - код обозначающий погодные условия (облачность, туман, снег и тд)
 date - дата запроса
 temp - температура воздуха
 text - дополнительный комментарий по погодным условиям
*/

#import <Foundation/Foundation.h>

@interface TSWeather : NSObject

-(id)initWithNameOfCity:(NSString *)city code:(NSString *)code date:(NSString *)date temp:(NSNumber *)temp
        text:(NSString *)text;
-(NSString *)city;
-(NSString *)code;
-(NSString *)date;
-(NSString *)text;
-(NSNumber *)temp;
@end
