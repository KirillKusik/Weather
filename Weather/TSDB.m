//
//  TSDB.m
//  Weather
//
//  Created by Admin on 14.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSDB.h"
#import "TSMySQLDB.h"
#import "TSAppDelegate.h"
@implementation TSDB


-(void) coreDataToMysql{
    TSAppDelegate *coreData = [TSAppDelegate new];
    TSMySQLDB *mysql = [TSMySQLDB new];
    for (NSDictionary *dic in coreData.linsArray) {
        [mysql addRecordToDatabase:dic];
        [coreData deleteRecordFromDatabase:[dic objectForKey:@"id"]];
        NSLog(@"test git");
    }
}

-(void) mysqlToCoreData{
    TSAppDelegate *coreData = [TSAppDelegate new];
    TSMySQLDB *mysql = [TSMySQLDB new];
    for (NSDictionary *dic in mysql.linsArray) {
        [coreData addRecordToDatabase:dic];
        [mysql deleteRecordFromDatabase:[[dic objectForKey:@"id"] integerValue]];
    }
}


-(void) removeUnneededRecords{
    if ([[TSSettings sharedController] DBType]){
        TSAppDelegate *coreData = [TSAppDelegate new];
        [coreData removeUnneededRecords];
    }
    else{
        TSMySQLDB *mysql = [TSMySQLDB new];
        [mysql removeUnneededRecords];    
    }
}

-(BOOL) addRecordToDatabase:(NSDictionary *)dictionary{
    if ([[TSSettings sharedController] DBType]){
        TSAppDelegate *coreData = [TSAppDelegate new];
        [coreData addRecordToDatabase:dictionary];
        return YES;
    }
    else{
        TSMySQLDB *mysql = [TSMySQLDB new];
        if([mysql addRecordToDatabase:dictionary])
            return YES;
        else
            return NO;
    }
}

-(BOOL)deleteRecordFromDatabase:(id)id{
    if ([[TSSettings sharedController] DBType]){
        TSAppDelegate *coreData = [TSAppDelegate new];
        [coreData deleteRecordFromDatabase:id];
        return YES;
    }
    else{
        TSMySQLDB *mysql = [TSMySQLDB new];
        if([mysql deleteRecordFromDatabase:[id integerValue]])
        return YES;
        else
        return NO;
    }
}

-(BOOL)refresh{
    if ([[TSSettings sharedController] DBType]){
        TSAppDelegate *coreData = [TSAppDelegate new];
        [coreData refresh];
        return YES;
    }
    else{
        TSMySQLDB *mysql = [TSMySQLDB new];
        if([mysql refresh])
        return YES;
        else
        return NO;
    }
}

-(NSArray *)getWeather{
    if ([[TSSettings sharedController] DBType]){
        TSAppDelegate *coreData = [TSAppDelegate new];
        return coreData.linsArray;
    }
    else{
        TSMySQLDB *mysql = [TSMySQLDB new];
        return mysql.linsArray;
    }
}

@end
