//
//  Widget.h
//  ActiveAging_v1.0
//
//  Created by Jimmy on 2017/3/26.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definitions.h"
#import "EventManager.h"
#import "ServerManager.h"

@interface Widget : NSObject
+ (void) widgetConfigurationWithTemperature: (NSString *) temperature  conditions:(NSString *) conditions complete:(DoneHandler) done;
@end
