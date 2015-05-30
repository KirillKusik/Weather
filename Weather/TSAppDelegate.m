//
//  TSAppDelegate.m
//  Weather
//
//  Created by Admin on 13.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSAppDelegate.h"

@implementation TSAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TSSettings sharedController];
    return YES;
}
							


@end
