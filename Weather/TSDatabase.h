/****************************************
 Класс хранит константы и описание общих метадов для управления базой данных 
*/

#import <Foundation/Foundation.h>
#import "TSSettings.h"

@interface TSDatabase : NSObject{
    NSMutableArray *arrayOfRecordsFromDatabase;
}

-(BOOL) removeUnneededRecords;
-(BOOL) addRecordToDatabase:(NSDictionary *)dictionary;
-(BOOL) deleteRecordFromDatabase:(NSUInteger)recordID;
-(NSArray *)getArrayOfRecordsFromDatabase;

@end
