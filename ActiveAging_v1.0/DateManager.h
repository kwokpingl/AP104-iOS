//
//  DateManager.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/15.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateManager : NSObject
+ (NSString *) convertDateOnly: (NSString *) dateString withFormatter:(NSDateFormatter *) formatter;
+ (NSString *) convertDateTime: (NSString *) dateString withFormatter:(NSDateFormatter *) formatter;
@end
