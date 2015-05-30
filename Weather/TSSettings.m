/*
 Класс настроек
 
 хранит и предоставляет тип активной базы данных и максимальное количество записей в ней
 */

#import "TSSettings.h"

static NSString * const kSettings_databaseType = @"DBType";
static NSString * const kSettings_databaseCount = @"DBCount";

@implementation TSSettings

@synthesize DBType,limitRecordsInDatabase;

static TSSettings *__sharedController = nil;

//Инициализация синглтона
+(instancetype)sharedController{
    
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{__sharedController = [[TSSettings alloc]init];
        [__sharedController restoreSettings];});
    return __sharedController;
}

//Загрузить настройки
-(void)restoreSettings{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.DBType = [[userDefaults objectForKey:kSettings_databaseType] boolValue];
    self.limitRecordsInDatabase = [[userDefaults objectForKey:kSettings_databaseCount] integerValue];
}

//Сохранить настройки
-(void)saveSettings{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(self.DBType) forKey:kSettings_databaseType];
    [userDefaults setObject:@(self.limitRecordsInDatabase) forKey:kSettings_databaseCount];
    [userDefaults synchronize];
}

@end
