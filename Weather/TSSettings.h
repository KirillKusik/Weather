//
//  TSSettings.h
//  Weather
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSSettings : NSObject

@property(nonatomic) BOOL DBType;
@property(nonatomic) NSUInteger limitRecordsInDatabase;

+(instancetype) sharedController;
-(void)saveSettings;

@end
