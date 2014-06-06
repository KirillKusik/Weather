//
//  TSMySQLDB.m
//  Weather
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSMySQLDB.h"
#import "TSXMLParser.h"
#import "TSSettings.h"

@implementation TSMySQLDB
@synthesize linsArray;

-(instancetype)init{
    self = [super init];
    if (self){
        hostAddres = [[TSSettings sharedController] addresDbHost];
        [self refresh];
    }
    return self;
}

-(void) removeUnneededRecords{
    
    for (NSInteger i = 0; [linsArray count] > [[TSSettings sharedController] DBCount]; i++) {
        NSDictionary * recordFoDeleted = [linsArray objectAtIndex:0];
        [self deleteRecord:[[recordFoDeleted objectForKey:@"id"] integerValue]];
        [self refresh];
    }
}

-(BOOL)addRecordToDatabase:(NSDictionary *) dictionary{
    
    BOOL ok = [self addRecord:dictionary];
    if (ok){
    [self refresh];
    [self removeUnneededRecords];
    [self refresh];
    }
    return ok;
}


-(BOOL) addRecord:(NSDictionary *) dictionary{
    
    NSString *requestString = [NSString stringWithFormat:@"http://%@/MySQLAPI.php?type=insert&city=%@&code=%@&date=%@&temp=%@&text=%@",hostAddres, [dictionary objectForKey:@"city"],[dictionary objectForKey:@"code"],[dictionary objectForKey:@"date"],[dictionary objectForKey:@"temp"],[dictionary objectForKey:@"text"]];
    NSString *request = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:request];
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    
    TSXMLParser *parserDelegate = [TSXMLParser new];
    self.parser.delegate = parserDelegate;
    [self.parser parse];
    
    while (! parserDelegate.parsDone)
    sleep(1);
    
    if (parserDelegate.error == nil ){
        if(parserDelegate.mysqlTransactionIsOk == true)
            return true;
        else
            return false;
    }
    else
        return false;
}

-(BOOL)deleteRecordFromDatabase:(NSUInteger)id{
    BOOL ok = [self deleteRecord:id];
    if (ok)
    [self refresh];
    return ok;
}


-(BOOL) deleteRecord:(NSUInteger)id{
    
    NSString *requestString = [NSString stringWithFormat:@"http://%@/MySQLAPI.php?type=delet&id=%@",hostAddres, [NSNumber numberWithInteger:id]];
    NSString *request = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:request];
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    
    TSXMLParser *parserDelegate = [TSXMLParser new];
    self.parser.delegate = parserDelegate;
    [self.parser parse];
    
    while (! parserDelegate.parsDone)
    sleep(1);
    
    if (parserDelegate.error == nil ){
        if(parserDelegate.mysqlTransactionIsOk == true){
            //[self refresh];
            return true;
        }
        else
        return false;
    }
    else
    return false;
}

-(BOOL)refresh{
    NSString *requestString = [NSString stringWithFormat:@"http://%@/MySQLAPI.php?type=select",hostAddres];
    NSString *request = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:request];

    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    
    TSXMLParser *parserDelegate = [TSXMLParser new];
    self.parser.delegate = parserDelegate;
    [self.parser parse];
    
    while (! parserDelegate.parsDone)
    sleep(1);
    
    if (parserDelegate.error == nil ){
        if(parserDelegate.mysqlLine == true){
            linsArray = parserDelegate.linsArray;
            return true;
        }
        else
        return false;
    }
    else
    return false;
}

@end
