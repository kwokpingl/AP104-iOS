//
//  ServerManager.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerManager : NSObject
@property (nonatomic, strong) NSString * message;
@property (nonatomic) BOOL passed;

+ (instancetype) shareInstance;

- (void) loginAuthorization:(NSString *) authorization
                   UserName:(NSString *) userName
            UserPhoneNumber:(NSString *) userPhoneNumber
                     Action:(NSString *) action;
@end
