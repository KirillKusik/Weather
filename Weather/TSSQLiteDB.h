#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "TSSettings.h"


static NSString * const kSqlDatabaseTableName = @"weatherInf";
static NSString * const kSqlDatabaseKey_ID = @"id";
static NSString * const kSqlDatabaseKey_City = @"city";
static NSString * const kSqlDatabaseKey_Code = @"code";
static NSString * const kSqlDatabaseKey_Date = @"date";
static NSString * const kSqlDatabaseKey_Temp = @"temp";
static NSString * const kSqlDatabaseKey_Text = @"text";

@interface TSSQLiteDB : NSObject{
    FMDatabase * sqLiteDatabase;
}
@property (nonatomic, readonly) NSError * sqLiteError;
    -(BOOL) removeUnneededRecords;
    -(BOOL) addRecordToDatabase:(NSDictionary *)dictionary;
    -(BOOL) deleteRecordFromDatabase:(NSUInteger)recordID;
    -(NSArray *)getArrayOfRecordsFromDatabase;
@end
