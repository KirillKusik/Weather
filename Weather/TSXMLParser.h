//
//  TSXMLParser.h
//  Wather
//
//  Created by Admin on 09.05.14.
//  Copyright (c) 2014 test. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSXMLParser : NSObject <NSXMLParserDelegate>
@property (readonly,nonatomic) BOOL parsDone;
@property (readonly,nonatomic) BOOL isWoeid;
@property (readonly,nonatomic) BOOL isYWeatherCondition;
@property (readonly,nonatomic) BOOL mysqlTransactionIsOk;
@property (readonly,nonatomic) BOOL mysqlLine;


@property (readonly,nonatomic) NSError *error;
@property (readonly,nonatomic) NSString *woeid;
@property (readonly,nonatomic) NSDictionary *weather;

@property (readonly,nonatomic) NSMutableArray *linsArray;

@end
