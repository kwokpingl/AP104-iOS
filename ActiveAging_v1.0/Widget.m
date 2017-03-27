//
//  Widget.m
//  ActiveAging_v1.0
//
//  Created by Jimmy on 2017/3/26.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "Widget.h"

@implementation Widget
+ (void) widgetConfigurationWithTemperature: (NSString *) temperature  conditions:(NSString *) conditions complete:(DoneHandler) done {
    NSUserDefaults * sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:WIDGET_NAME];
    
    if (temperature != nil){
        [sharedDefaults setObject:temperature forKey:@"currentTempTxt"];
    }
    if (conditions != nil){
        [sharedDefaults setObject:conditions forKey:@"currentConditions"];
    }
    
    
    [[EventManager shareInstance] sortTimeOrder:[NSDate date] complete:^(NSMutableArray *eventArray) {
        NSMutableArray * eventsForWidget = [[NSMutableArray alloc] initWithArray:eventArray];
        
        EKEvent * event;
        NSString * dateStr;
        NSString * eventTitle;
        
        NSMutableArray * widgetEvent = [NSMutableArray new];
        
        if (eventsForWidget.count != 0) {
            
            for (int i = 0; i < eventsForWidget.count; i++) {
                event = [eventsForWidget objectAtIndex:i];
                
                NSDateFormatter * today = [NSDateFormatter new];
                today.dateFormat = @"HH:mm";
                dateStr = [today stringFromDate:event.startDate];
                eventTitle = event.title;
                
                NSMutableDictionary * dict = [NSMutableDictionary new];
                dict = [@{@"today date":dateStr, @"event title":eventTitle} mutableCopy];
                
                if (([dateStr floatValue] + 1 )>= [[today stringFromDate:[NSDate date]] floatValue]){
                    [widgetEvent addObject:dict];
                    //the first object contains the latest date and title...
                }
            }
        }
        
        [sharedDefaults setObject:widgetEvent forKey:@"eventsArray"];
        [sharedDefaults synchronize];
        done(nil, @(true));
    }];
}


@end
