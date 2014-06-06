//
//  TSDB.h
//  Weather
//
//  Created by Admin on 14.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>
#import "TSSettings.h"

@interface TSDB : NSObject

-(BOOL) addRecordToDatabase:(NSDictionary *) dictionary;
-(BOOL) deleteRecordFromDatabase:(id)id;
-(BOOL)refresh;
-(void) removeUnneededRecords;

-(NSArray *) getWeather;

-(void)mysqlToCoreData;
-(void)coreDataToMysql;

@end
