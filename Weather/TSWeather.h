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

@property (nonatomic) NSString *city;
@property (nonatomic) NSString *code;
@property (nonatomic) NSString *date;
@property (nonatomic) NSNumber *temp;
@property (nonatomic) NSString *text;

-(id)initWithNameOfCity:(NSString *)city code:(NSString *)code date:(NSString *)date temp:(NSNumber *)temp
        text:(NSString *)text;

@end
