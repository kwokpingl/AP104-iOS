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
                      @"800" : @"weather-clear",
                      @"801" : @"few-day",
                      @"802" : @"few-day",
                      @"803" : @"broken", //04d
                      @"804" : @"broken", //04d
                      
                      @"300" : @"shower", //09d
                      @"301" : @"shower",
                      @"302" : @"shower",
                      @"310" : @"shower",
                      @"311" : @"shower",
                      @"312" : @"shower",
                      @"313" : @"shower",
                      @"314" : @"shower",
                      @"321" : @"shower",
                      @"520" : @"shower",
                      @"521" : @"shower",
                      @"522" : @"shower",
                      @"523" : @"shower",
                      @"531" : @"shower",
                      
                      @"500" : @"rain", //10d
                      @"501" : @"rain", //img check
                      @"502" : @"rain",
                      @"503" : @"rain",
                      @"504" : @"rain",
                      
                      @"200" : @"tstorm", //11d
                      @"201" : @"tstorm", //img check
                      @"202" : @"tstorm",
                      @"210" : @"tstorm",
                      @"211" : @"tstorm",
                      @"212" : @"tstorm",
                      @"221" : @"tstorm",
                      @"230" : @"tstorm",
                      @"231" : @"tstorm",
                      @"232" : @"tstorm",
                      
                      @"511" : @"snow", //13d - freezing rain
                      @"600" : @"snow", //snow
                      @"601" : @"snow",
                      @"602" : @"snow",
                      @"611" : @"snow",
                      @"612" : @"snow",
                      @"615" : @"snow",
                      @"616" : @"snow",
                      @"620" : @"snow",
                      @"621" : @"snow",
                      @"622" : @"snow",
                      
                      @"701" : @"mist", //50d
                      @"711" : @"mist",
                      @"721" : @"mist",
                      @"731" : @"mist",
                      @"741" : @"mist",
                      @"751" : @"mist",
                      @"761" : @"mist",
                      @"762" : @"mist",
                      @"771" : @"mist",
                      @"781" : @"mist",
                      
                      @"800" : @"moon", //01n //img check
//                      @"801" : @"few", //02n //img check
//                      @"802" : @"few", //03n
                      @"803" : @"broken", //04n
                      @"804" : @"broken", //04n //img check
//                      @"09n" : @"weather-shower",
//                      @"10n" : @"weather-rain-night",
//                      @"11n" : @"weather-tstorm",
//                      @"13n" : @"weather-snow",
//                      @"50n" : @"weather-mist",
                      @"962" : @"typhoon",  //img check
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
        return [NSString stringWithFormat:@"%@",[weather.firstObject valueForKey:@"id"]];
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
