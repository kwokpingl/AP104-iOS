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


@interface KeychainManager : NSObject

@property (nonatomic,strong) NSMutableDictionary * vcKeyData;
@property (nonatomic, strong) NSMutableDictionary * genericQuery;
@property (nonatomic, strong) NSString * errorString;

+ (instancetype) sharedInstance;

- (BOOL) foundKeychain;
- (NSData *) getKeychainObjectForKey : (NSString *) key;
- (BOOL) setKeychainObject : (NSString *) object
                     forKey: (NSString *) key;
//- (void) resetKeychain;
- (void) retrieveUserInfo;

@end
