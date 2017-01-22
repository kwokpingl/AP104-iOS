//
//  KeychainManager.h
//  TestActiveAging
//
//  Created by Kwok Ping Lau on 1/15/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "Definitions.h"

typedef void (^USERINFO)(NSString * userName, NSString * userPhoneNumber);

@interface KeychainManager : NSObject

@property (nonatomic,strong) NSMutableDictionary * vcKeyData;
@property (nonatomic, strong) NSMutableDictionary * genericQuery;
@property (nonatomic, strong) NSString * errorString;

+ (instancetype) sharedInstance;

//- (BOOL) foundKeychain;
- (BOOL) foundKeychain: (USERINFO) userinfo;
- (NSData *) getKeychainObjectForKey : (NSString *) key;
- (BOOL) setKeychainObject : (NSString *) object
                     forKey: (NSString *) key;
//- (void) resetKeychain;
//- (void) retrieveUserInfo;
- (void) retrieveUserInfo: (USERINFO) userinfo;

- (void) deleteKeychain: (NSString *) username Password: (NSString *) userPassword;

@end
