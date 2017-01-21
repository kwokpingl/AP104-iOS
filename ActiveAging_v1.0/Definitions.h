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
#define BASE_URL                @"http://activeaging.xp3.biz"
#define LOGIN_URL               [BASE_URL stringByAppendingPathComponent:@"php/login.php"]


#define AUTHORIZATION_KEY       @"authorization"
#define ID_KEY                  @"id"
#define USER_NAME_KEY           @"userName"
#define USER_PASSWORD_KEY       @"userPassword"
#define USER_PHONENUMBER_KEY    @"userPhoneNumber"
#define ACTION_KEY              @"action"
    #define ACTION_CHECK        @"checkAvailability"
    #define ACTION_ADD          @"create"
#define DATA_KEY                @"data"


// SEND PICTURE
#define UPLOAD_PIC_URL          [BASE_URL stringByAppendingPathComponent:@"php/uploadImage.php"]


// KEYCHAIN_ITEM
#define keyAttrLabel        @"ActiveAging Login"
#define keyAttrDescription  @"This is your login password for Acitve Aging"
#define keyAttrService      @"biz.xp3.activeaging_test5"


#endif /* Definitions_h */
