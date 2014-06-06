//
//  TSMySQLDB.h
//  Weather
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSMySQLDB : NSObject{
    NSString *hostAddres;
}
@property (nonatomic,strong) NSXMLParser *parser;
@property (readonly,nonatomic) NSMutableArray *linsArray;

-(void) removeUnneededRecords;
-(BOOL) addRecordToDatabase:(NSDictionary *) dictionary;
-(BOOL) deleteRecordFromDatabase:(NSUInteger)id;
-(BOOL)refresh;
@end
