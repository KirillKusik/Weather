/*
 Класс работает с обеими (SQLait и CoreData) базами данных автоматически подключаясь к той,
 которая сейчас указана активной в настройках
*/

#import "TSWeather.h"
#import "TSWeatherDatabase.h"
#import "TSWeatherSQLite.h"
#import "TSWeatherCoreData.h"

static NSString *kDatabaseSettings_databaseType = @"DBType";
static NSString *kDatabaseSettings_databaseCount = @"DBCount";
static TSWeatherDatabase *__sharedWeatherDatabase = nil;

@interface TSWeatherDatabase ()
@property DatabaseType databaseType;
@property NSUInteger databaseCount;
@property (nonatomic) NSError *error;
@end

@implementation TSWeatherDatabase

#pragma mark - Database Initialization
+(instancetype)sharedDatabase {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{__sharedWeatherDatabase = [[TSWeatherDatabase alloc] init];
        [__sharedWeatherDatabase restoreSettings];});
    return __sharedWeatherDatabase;
}

-(void)restoreSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.databaseType = [[userDefaults objectForKey:kDatabaseSettings_databaseType] boolValue];
    NSUInteger count = [[userDefaults objectForKey:kDatabaseSettings_databaseCount] integerValue];
    if (count == 0) {
        self.databaseCount = 5;
    } else {
        self.databaseCount = count;
    }
}

#pragma mark - Change database settings
-(void)migrateToDatabase:(DatabaseType)databaseType {
    if (self.databaseType != databaseType) {
        self.databaseType = databaseType;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@(self.databaseType) forKey:kDatabaseSettings_databaseType];
        [userDefaults synchronize];
        if (self.databaseType == SQLiteDatabaseType) {
            TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
            NSArray *weatherArray = [coreData getWeatherArray];
            TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
            for (TSWeather *weather in weatherArray) {
                [sqLite addWeather:weather];
                [coreData deleteWeather:weather];
            }
        } else if (self.databaseType == CoreDataDatabaseType) {
            TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
            NSArray *weatherArray = [sqLite getWeatherArray];
            TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
            for (TSWeather *weather in weatherArray) {
                [coreData addWeather:weather];
                [sqLite deleteWeather:weather];
            }
        }
    }
}

-(void)setMaxRecordsValueInDatabase:(NSUInteger)maxRecordsValue {
    if (self.databaseCount != maxRecordsValue) {
        self.databaseCount = maxRecordsValue;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@(self.databaseCount) forKey:kDatabaseSettings_databaseCount];
        [userDefaults synchronize];
        if (self.databaseType == CoreDataDatabaseType) {
            TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
            [coreData setCountRecords:self.databaseCount];
        } else if (self.databaseType == SQLiteDatabaseType) {
            TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
            [sqLite setCountRecords:self.databaseCount];
        } else {
            [self generateDatabaseTypeError];
        }
    }
}

#pragma mark - Returns database parameters
-(NSUInteger)maxRecordsValueInDatabase {
    return self.databaseCount;
}

-(NSUInteger)recordsCount {
    return [[self getAllWeathers] count];
}

#pragma mark - Methods of adding, deleting, and getting the content database
-(BOOL)addWeather:(TSWeather *)weather {
    if (self.databaseType == CoreDataDatabaseType) {
        TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
        if ([coreData addWeather:weather]) {
            [coreData setCountRecords:self.databaseCount];
            return YES;
        } else {
            self.error = coreData.error;
            return NO;
        }
    }
    else if (self.databaseType == SQLiteDatabaseType) {
        TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
        if ([sqLite addWeather:weather]) {
            [sqLite setCountRecords:self.databaseCount];
            return YES;
        } else {
            self.error = sqLite.error;
            return NO;
        }
    } else {
        [self generateDatabaseTypeError];
        return NO;
    }
}

-(BOOL)deleteWeather:(TSWeather *)weather {
    if (self.databaseType == CoreDataDatabaseType) {
        TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
        if ([coreData deleteWeather:weather]) {
            return YES;
        } else {
            self.error = coreData.error;
            return NO;
        }
    }
    else if (self.databaseType == SQLiteDatabaseType) {
        TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
        if ([sqLite deleteWeather:weather]) {
            return YES;
        } else {
            self.error = sqLite.error;
            return NO;
        }
    } else {
        [self generateDatabaseTypeError];
        return NO;
    }
}

-(NSArray *)getAllWeathers {
    if (self.databaseType == CoreDataDatabaseType) {
        TSWeatherCoreData *coreData = [[TSWeatherCoreData alloc] init];
        NSArray *weatherArray = [coreData getWeatherArray];
        if ([weatherArray count] > 0) {
            return weatherArray;
        } else {
            self.error = coreData.error;
            return nil;
        }
    }
    else if (self.databaseType == SQLiteDatabaseType){
        TSWeatherSQLite *sqLite = [[TSWeatherSQLite alloc] init];
        NSArray *weatherArray = [sqLite getWeatherArray];
        if ([weatherArray count] > 0) {
            return weatherArray;
        } else {
            self.error = sqLite.error;
            return nil;
        }
    } else {
        [self generateDatabaseTypeError];
        return nil;
    }
}

#pragma mark - Errors metods
-(void)generateDatabaseTypeError {
    [self generateErrorWithDomain:@"Database Error" ErrorMessage:@"Database type error"
            Description:@"Unknown type of database"];
}

-(void)generateErrorWithDomain:(NSString *)domain ErrorMessage:(NSString *)message
            Description:(NSString *)description {
    NSArray *objArray = [NSArray arrayWithObjects:description, message, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey,
            nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    self.error = [NSError errorWithDomain:domain code:1 userInfo:userInfo];
}
@end
