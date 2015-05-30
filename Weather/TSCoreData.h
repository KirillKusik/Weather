/*
 Клас обеспечивает связь с базой данных Core Data 
*/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TSDatabasePreform.h"



@interface TSCoreData :TSDatabasePreform

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//Метод добавляет объект Weather в базу данных
//Если количество записей в базе подошло к ограничительному значению
//сначала будет удалина самая старая запись
-(BOOL) addRecordToDatabase:(Weather *)weather;

//метод удаляет объект Weather из базы
//если указанное значение не соответствует ни одной записи из базы
//генерируется ошибка и метод возвращает ложное значение
-(BOOL) deleteRecordFromDatabase:(Weather *)weather;

//возврашает масив объектов Weather хранящихся в базе данных
-(NSArray *)getArrayOfRecordsFromDatabase;

//Если количество записей подошло к ограничительному значению метод удалить самую старую запись
//при полнастью заполненой базе после выполнения метода в ней останется столько записей сколько указанно в настройках
-(void)removeUnneededRecords;

@end
