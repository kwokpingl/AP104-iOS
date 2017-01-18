//
//  UserInfo.m
//  TestActiveAging
//
//  Created by Kwok Ping Lau on 1/17/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "UserInfo.h"

static UserInfo * userInfo = nil;

@implementation UserInfo{
    NSString * _username;
    NSString * _password;
}
+ (instancetype) shareInstance{
    if (userInfo == nil){
        userInfo = [UserInfo new];
    }
    return userInfo;
}


- (void) setUserInfo: (NSString *) username userPassword: (NSString *) password{
    _username = username;
    _password = password;
}

- (NSString *) getUsername{
    return _username;
}

- (NSString *) getPassword{
    return _password;
}
@end
