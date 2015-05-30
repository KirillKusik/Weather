/*
 Класс работает с обееми (SQLait и CoreData) базами данных автоматически подключаясь к той,
 которая сейчас указана активной в настройках
 */

#import <Foundation/Foundation.h>
#import "TSDatabasePreform.h"

@interface TSDatabase : TSDatabasePreform

//Метод добавляет значения (класс Weather) в базу данных
//которая на данный момен указанна в настройках как активная
//Если запись не произошла па какойто причине метод возвращает NO
//и генерирует в даных класса error
-(BOOL)addRecordToDatabase:(Weather *)weather;

//Метод удаляет значения (класс Weather) из базы данных
//которая на данный момен указанна в настройках как активная
//Если удаление не произошло па какойто причине метод возвращает NO
//и генерирует в даных класса error
-(BOOL)deleteRecordFromDatabase:(Weather *)weather;

//Возврашает массив объектов типа Weather из активной на данный момент базы
-(NSArray *)getArrayOfRecordsFromDatabase;

//Метод удалит лишние поля (начиная от самых старых)
//если в базе данных полей больше чем указанно в настройках
-(void)removeUnneededRecords;

//Метод копирует поля из coreData в SQLite после чего очишает исходную базу
-(void)sqlToCoreData;

//Метод копирует поля из SQLite в coreData после чего очишает исходную базу
-(void)coreDataToSql;




@end
