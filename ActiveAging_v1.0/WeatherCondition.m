//
//  WeatherCondition.m
//  Weather
//
//  Created by Ga Wai Lau on 1/29/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import "WeatherCondition.h"

#define MPS_TO_MPH 2.23694f

@implementation WeatherCondition

+(NSDictionary * ) imageMap {
    //Create a static NSDictionary since every instance of WXCondition will use the same data mapper.
    static NSDictionary * _imageMap = nil;
    
    //Map the condition codes to an image file (e.g. “01d” to “weather-clear.png”)
    if (!_imageMap) {
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

-(NSString *) imageName {
    //Declare the public message to get an image file name
    return [WeatherCondition imageMap][self.icon];
}

#pragma mark - JSON Key Path By Property Key
//setup “JSON to model properties” mappings by adding the +JSONKeyPathsByPropertyKey method that the MTLJSONSerializing protocol requires
//the dictionary key is weatherCondition‘s property name, while the dictionary value is the keypath from the JSON
//The property date is of type NSDate, but the JSON has an NSInteger stored as Unix time. You’ll need to convert between the two using MTLValueTransformer
+(NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
//             @"conditionDescription": @"weather.description",
             @"conditionDescription": @"weather",
//             @"condition": @"weather.main",
             @"condition":@"weather",
//             @"icon": @"weather.icon",
             @"icon": @"weather",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

#pragma mark - MTLValueTransformer
// return a MTLValueTransformer using blocks to transform values to and from Objective-C properties
+(NSValueTransformer *) dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString * str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate * date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

//need to detail how to convert between Unix time and NSDate once, so just reuse -dateJSONTransformer for sunrise and sunset
+(NSValueTransformer *) sunriseJSONTransformer {
    return [self dateJSONTransformer];
}

+(NSValueTransformer *) sunsetJSONTransformer {
    return [self dateJSONTransformer];
}

//+(NSValueTransformer *) conditionDescriptionJSONTransformer {
//    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray * values){
//        return [values firstObject];
//    } reverseBlock:^(NSString * str) {
//        return @[str];
//    }];
//}

+ (NSValueTransformer *)conditionDescriptionJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *weather, BOOL *success, NSError **error) {
        return [weather.firstObject valueForKey:@"description"];
    }];
}

+(NSValueTransformer *) conditionJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

+(NSValueTransformer *) iconJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *weather, BOOL *success, NSError **error) {
        return [weather.firstObject valueForKey:@"icon"];
    }];
}

//OpenWeatherAPI uses meters-per-second for wind speed
//convert this to miles-per-hour
+(NSValueTransformer *) windSpeedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber * num) {
        return @(num.floatValue * MPS_TO_MPH);
    } reverseBlock:^(NSNumber * speed) {
        return @(speed.floatValue/MPS_TO_MPH);
    }];
}

@end
