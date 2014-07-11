#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TSSQLiteDB.h"
#import "TSCoreDataDB.h"


@interface TSDB : NSObject
    
@property (nonatomic, readonly) NSError *dbError;

-(void) sqlToCoreData;
-(void) coreDataToSql;
-(BOOL) deleteRecordFromDatabase:(id)recordID;
-(BOOL) removeUnneededRecords;
-(BOOL) addRecordToDatabase:(NSDictionary *)dictionary;
-(NSArray *)getArrayOfRecordsFromDatabase;
@end
