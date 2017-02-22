//
//  DateManager.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/15.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "DateManager.h"

@implementation DateManager
+ (NSString *) convertDateOnly: (NSString *) dateString withFormatter:(NSDateFormatter *) formatter{
    NSString * finalDate;
    
    NSDate * date = [formatter dateFromString:dateString];
    formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSLocale * locale = [NSLocale currentLocale];
    NSString * language = [locale objectForKey:NSLocaleLanguageCode];
    NSString * format = @"dd MMM yyyy";
    if ([language containsString:@"zh"]){
        format = [NSDateFormatter dateFormatFromTemplate:format options:0 locale:locale];
        [formatter setDateFormat:format];
        finalDate = [formatter stringFromDate:date];
    }
    else{
        finalDate = [formatter stringFromDate:date];
    }
    
    return finalDate;
}

+ (NSString *) convertDateTime: (NSString *) dateString withFormatter:(NSDateFormatter *) formatter{
    NSString * finalDate;
    
    NSDate * date = [formatter dateFromString:dateString];
    formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSLocale * locale = [NSLocale currentLocale];
    NSString * language = [locale objectForKey:NSLocaleLanguageCode];
    NSString * format = @"dd MMM yyyy HH:mm";
    if ([language containsString:@"zh"]){
        format = [NSDateFormatter dateFormatFromTemplate:format options:0 locale:locale];
        [formatter setDateFormat:format];
        finalDate = [formatter stringFromDate:date];
    }
    else{
        finalDate = [formatter stringFromDate:date];
    }
    
    return finalDate;
}



@end
