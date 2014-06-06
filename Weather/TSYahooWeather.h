//
//  TSYahooWeather.h
//  Weather
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSXMLParser.h"

@interface TSYahooWeather : NSObject
-(NSString *) getWoeid:(NSString *)city;
-(NSDictionary *) getWeather:(NSString *)woeid;
@end
