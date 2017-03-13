//
//  UserInfo.h
//  TestActiveAging
//
//  Created by Kwok Ping Lau on 1/17/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserInfo : NSObject
+ (instancetype) shareInstance;

- (void) setUserInfo: (NSString *) username userPassword: (NSString *) password;
- (void) setProfileImage: (UIImage *) img;
- (void) setUserID:(NSInteger)userID;
- (void) setDeviceToken: (NSString *) deviceToken;

- (NSString *) getUsername;
- (NSString *) getPassword;
- (UIImage *) getProfileImage;
- (NSInteger) getUserID;
- (NSString *) getDeviceToken;
- (BOOL) isShareLocation;
- (void) changeShareLocation;
@end
