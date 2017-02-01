//
//  WeatherDailyForecast.m
//  Weather
//
//  Created by Ga Wai Lau on 1/29/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import "WeatherDailyForecast.h"

@implementation WeatherDailyForecast

//override +JSONKeyPathsByPropertyKey
//change the key mapping for daily forecasts
//Get WeatherCondition‘s map and create a mutable copy of it
//Change the max and min key maps to what is needed for the daily forecast.
//Return the new mapping
+(NSDictionary *) JSONKeyPathsByPropertyKey {
    //1
    NSMutableDictionary * paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    //2
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    //3
    return paths;
}

@end
