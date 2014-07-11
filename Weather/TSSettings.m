//
//  TSSettings.m
//  Weather
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSSettings.h"

@implementation TSSettings
@synthesize DBType,limitRecordsInDatabase;

static TSSettings *__sharedController = nil;

+(instancetype)sharedController{    
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{__sharedController = [[TSSettings alloc]init];
        [__sharedController resoreSettings];});
    return __sharedController;
}

-(void)resoreSettings{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.DBType = [[userDefaults objectForKey:@"DBType"] boolValue];
    self.limitRecordsInDatabase = [[userDefaults objectForKey:@"DBCount"] integerValue];
}

-(void)saveSettings{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(self.DBType) forKey:@"DBType"];
    [userDefaults setObject:@(self.limitRecordsInDatabase) forKey:@"DBCount"];
    [userDefaults synchronize];
}

@end
