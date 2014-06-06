//
//  TSXMLParser.m
//  Wather
//
//  Created by Admin on 09.05.14.
//  Copyright (c) 2014 test. All rights reserved.
//

#import "TSXMLParser.h"

@implementation TSXMLParser 
@synthesize woeid, isWoeid, isYWeatherCondition, parsDone, error, weather,mysqlTransactionIsOk,mysqlLine,linsArray;

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    parsDone = NO;
    isWoeid = NO;
    isYWeatherCondition = NO;
    mysqlTransactionIsOk = NO;
    mysqlLine = NO;
    linsArray = [NSMutableArray array];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    parsDone = YES;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    parsDone = YES;
    error = parseError;
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError{
    parsDone = YES;
    error = validationError;
}

-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    isWoeid = [[elementName lowercaseString] isEqualToString:@"woeid"];
    
    isYWeatherCondition = [[elementName lowercaseString] isEqualToString:@"yweather:condition"];
    if (isYWeatherCondition)
        weather = [[NSDictionary alloc] initWithDictionary:attributeDict];
    
    if(mysqlTransactionIsOk == true){
        mysqlLine = [[elementName lowercaseString] isEqualToString:@"line"];
        if(mysqlLine)
        [linsArray addObject:attributeDict];
    }
    
    if([[elementName lowercaseString] isEqualToString:@"isok"]){
        mysqlTransactionIsOk = true;
    }
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    //найден конец элемента
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (isWoeid == YES)
        {
            isWoeid = NO;
            if (!woeid){
                woeid = [NSString new];
                woeid = string;
            }
        }
    //NSLog(@"%@",string);
}
@end
