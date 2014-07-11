#import <Foundation/Foundation.h>
#import "TSSettings.h"

static NSString * const kDatabaseTableName = @"weatherInf";
static NSString * const kDatabaseKey_ID = @"id";
static NSString * const kDatabaseKey_City = @"city";
static NSString * const kDatabaseKey_Code = @"code";
static NSString * const kDatabaseKey_Date = @"date";
static NSString * const kDatabaseKey_Temp = @"temp";
static NSString * const kDatabaseKey_Text = @"text";

@interface TSBaseDB : NSObject
@property (nonatomic, readonly) NSError * DBError;
-(BOOL) removeUnneededRecords;
-(BOOL) addRecordToDatabase:(NSDictionary *)dictionary;
-(BOOL) deleteRecordFromDatabase:(NSUInteger)recordID;
-(NSArray *)getArrayOfRecordsFromDatabase;
-(void)generateErrorWithDomain:(NSString *)domain ErrorMessage:(NSString *)message Description:(NSString *)description;
@end
