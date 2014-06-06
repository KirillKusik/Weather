//
//  WeatherDB.h
//  Weather
//
//  Created by Admin on 26.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WeatherDB : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSNumber * temp;
@property (nonatomic, retain) NSString * text;

@end
