/*
 Класс настроек
 
 хранит и предоставляет тип активной базы данных и максимальное количество записей в ней
 */

#import "TSSettings.h"

static NSString * kSettings_databaseType = @"DBType";
static NSString * kSettings_databaseCount = @"DBCount";

@implementation TSSettings

static TSSettings *__sharedSettings = nil;

+(instancetype)sharedSettings{
    
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{__sharedSettings = [[TSSettings alloc]init];
        [__sharedSettings restoreSettings];});
    return __sharedSettings;
}

//Загрузить настройки
-(void)restoreSettings{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _databaseType = [[userDefaults objectForKey:kSettings_databaseType] boolValue];
    _databaseCount = [[userDefaults objectForKey:kSettings_databaseCount] integerValue];
}

//Сохранить настройки
-(void)saveSettings{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(self.databaseType) forKey:kSettings_databaseType];
    [userDefaults setObject:@(self.databaseCount) forKey:kSettings_databaseCount];
    [userDefaults synchronize];
}

@end
