/*
 Класс обеспечивает связь с базой данных Core Data
*/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TSWeatherDatabasePreform.h"

@interface TSWeatherCoreData :NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSError *error;

//Метод добавляет объект Weather в базу данных
//Если количество записей в базе подошло к ограничительному значению
//сначала будет удалена самая старая запись
-(BOOL)addWeather:(TSWeather *)weather;

//метод удаляет объект Weather из базы
//если указанное значение не соответствует ни одной записи из базы
//генерируется ошибка и метод возвращает ложное значение
-(BOOL)deleteWeather:(TSWeather *)weather;

//возвращает массив объектов Weather хранящихся в базе данных
-(NSArray *)getWeatherArray;

//Если количество записей подошло к ограничительному значению метод удалить самую старую запись
//при полностью заполненной базе после выполнения метода в ней останется столько записей сколько указанно в настройках
-(void)setCountRecords:(NSUInteger)count;

@end
