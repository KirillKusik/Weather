/*
 Класс настроек
 
 хранит и предоставляет тип активной базы данных и максимальное количество записей в ней
 */

#import <Foundation/Foundation.h>

typedef enum {
    CoreDataDatabaseType,
    SQLiteDatabaseType
} DatabaseType;

@interface TSSettings : NSObject

@property(nonatomic) DatabaseType DBType;
@property(nonatomic) NSUInteger limitRecordsInDatabase;

//Инициализация синглтона
+(instancetype) sharedController;

//Сохранить настройки
-(void)saveSettings;

@end
