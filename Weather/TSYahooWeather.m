//
//  TSYahooWeather.m
//  Weather
//
//  Created by Admin on 19.05.14.
//  Copyright (c) 2014 123. All rights reserved.
//

#import "TSYahooWeather.h"
#import "TSXMLParser.h"

@interface TSYahooWeather(){
NSXMLParser *parser;
}
@end

@implementation TSYahooWeather

-(NSString *) getWoeid:(NSString *)city{
    NSString *requestWoeid = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=select * from geo.places where text=\"%@\"&format=xml", city];
    NSString *encRequestWoeid = [requestWoeid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URLWoeid = [NSURL URLWithString:encRequestWoeid];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:URLWoeid];
    
    TSXMLParser *parserDelegate = [TSXMLParser new];
    parser.delegate = parserDelegate;
    [parser parse];
    
    while (! parserDelegate.parsDone)
    sleep(1);
    
    if (parserDelegate.error == nil)
        return  parserDelegate.woeid;
    else
        return nil;
}

-(NSDictionary *) getWeather:(NSString *)woeid{
        NSString *encRequestWeather = [[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%@&u=c", woeid] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *URLWeather = [NSURL URLWithString:encRequestWeather];
        parser = [[NSXMLParser alloc] initWithContentsOfURL:URLWeather];
        
        TSXMLParser *parserDelegate = [TSXMLParser new];
        parser.delegate = parserDelegate;
        [parser parse];
        
        while (! parserDelegate.parsDone)
        sleep(1);
        
        if (parserDelegate.error == nil)
            return parserDelegate.weather;
        else
            return nil;
}

@end
