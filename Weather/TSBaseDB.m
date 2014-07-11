//
//  TSBaseDB.m
//  Weather
//
//  Created by Admin on 11.07.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSBaseDB.h"

@implementation TSBaseDB
@synthesize DBError;
-(void)generateErrorWithDomain:(NSString *)domain ErrorMessage:(NSString *)message Description:(NSString *)description{
    NSArray *objArray = [NSArray arrayWithObjects:description, message, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    DBError = [NSError errorWithDomain:domain code:1 userInfo:userInfo];
}
@end
