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

@property (nonatomic, readonly) NSString * city;
@property (nonatomic, readonly) NSString * code;
@property (nonatomic, readonly) NSString * date;
@property (nonatomic, readonly) NSNumber * temp;
@property (nonatomic, readonly) NSString * text;


//Инициализация объекта Weather с параметрами
-(id)initWithNameOfCity:(NSString *)city
                   code:(NSString *)code
                   date:(NSString *)date
                   temp:(NSNumber *)temp
                   text:(NSString *)text;

@end
