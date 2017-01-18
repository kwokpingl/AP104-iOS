//
//  Definitions.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#ifndef Definitions_h
#define Definitions_h

// SERVER
#define BASE_URL            @"http://activeaging.xp3.biz"
#define LOGIN_URL           [BASE_URL stringByAppendingPathComponent:@"php/login.php"]
#define ID_KEY              @"id"
#define USER_NAME_KEY       @"userName"
#define USER_PASSWORD       @"userPassword"
#define USER_PHONENUMBER    @"userPhoneNumber"
#define ACTION              @"action"
#define DATA_KEY            @"data"

// KEYCHAIN_ITEM
#define keyAttrLabel        @"ActiveAging Login"
#define keyAttrDescription  @"This is your login password for Acitve Aging"
#define keyAttrService      @"biz.xp3.activeaging_test5"

#endif /* Definitions_h */
