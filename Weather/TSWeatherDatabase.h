/*
 Класс работает с обеими (SQLait и CoreData) базами данных автоматически подключаясь к той,
 которая сейчас указана активной в настройках
 */

#import <Foundation/Foundation.h>
#import "TSWeatherDatabasePreform.h"
#import "TSSettings.h"

@class TSWeather;

@interface TSWeatherDatabase : NSObject{
    DatabaseType databaseType;
    NSUInteger databaseCount;
}

@property (nonatomic, readonly) NSError *error;

-(instancetype)initWithSettings:(TSSettings *)settings;

//Метод добавляет значения (класс Weather) в базу данных
//которая на данный момент указанна в настройках как активная
//Если запись не произошла па какой-то причине метод возвращает NO
//и генерирует error
-(BOOL)addWeather:(TSWeather *)weather;

//Метод удаляет значения (класс Weather) из базы данных
//которая на данный момент указанна в настройках как активная
//Если удаление не произошло па какой-то причине метод возвращает NO
//и генерирует в данных класса error
-(BOOL)deleteWeather:(TSWeather *)weather;

//Возвращает массив объектов типа Weather из активной на данный момент базы
-(NSArray *)getAllWeathers;

//Метод удалит лишние поля (начиная от самых старых)
//если в базе данных полей больше чем указанно в настройках
-(void)removeSurplusRecords;

//Метод копирует поля из coreData в SQLite после чего очищает исходную базу
-(void)sqlToCoreData;

//Метод копирует поля из SQLite в coreData после чего очищает исходную базу
-(void)coreDataToSql;




@end
