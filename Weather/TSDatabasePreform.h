/*
 Этот класс основа для классов баз данных.
 
 Здесь объявленны константы с именами полей используемых в бд и методы.
 */

#import <Foundation/Foundation.h>
#import "Weather.h"

static NSString * const kDatabaseTableName = @"Weather";
static NSString * const kDatabaseKey_ID = @"id";
static NSString * const kDatabaseKey_City = @"city";
static NSString * const kDatabaseKey_Code = @"code";
static NSString * const kDatabaseKey_Date = @"date";
static NSString * const kDatabaseKey_Temp = @"temp";
static NSString * const kDatabaseKey_Text = @"text";

@interface TSDatabasePreform : NSObject
@property (nonatomic, readonly) NSError * error;

-(void)generateErrorWithDomain:(NSString *)domain
                  ErrorMessage:(NSString *)message
                   Description:(NSString *)description;

@end
