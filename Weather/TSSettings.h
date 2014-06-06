//
//  TSSettings.h
//  Weather
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSSettings : NSObject{
    BOOL DBType;
    NSUInteger DBCount;
    NSString *addresDbHost;
}
@property(nonatomic) BOOL DBType;
@property(nonatomic) NSUInteger DBCount;
@property(nonatomic) NSString *addresDbHost;


/*-(void) setDBType:(BOOL)type;
-(BOOL) DBType;

-(void) setDBCount:(NSUInteger)count;
-(NSUInteger)DBCount;
*/


+(instancetype) sharedController;

-(void)saveSettings;

@end
