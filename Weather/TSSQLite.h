/*
 Класс обеспечивает доступ к базе данных SQLite.
 
 Класс специализирует базу ограничивая лишние функции которые не применяются в данном приложении.
 Также берет на себя формирование SQL запросов.
 
 Для подключения к базе испльзуется оболочка fmdb.
 */
#import <Foundation/Foundation.h>
#import "TSDatabasePreform.h"

@interface TSSQLite : TSDatabasePreform

//метод добавляет экземпляр класса Weather в базу данных SQLite
//и следит что-бы база не содержала лишних записей
-(BOOL)addRecordToDatabase:(Weather *)weather;

//метод удаляет указанный объект из базы
-(BOOL)deleteRecordFromDatabase:(Weather *)weather;

//метод возврашает масив всех записей (NSDictionary) хранящихся в базе SQLite
-(NSArray *)getArrayOfRecordsFromDatabase;

//метод удаляет старые записи если их боьше чем указанно в настройках
-(void)removeUnneededRecords;
@end
