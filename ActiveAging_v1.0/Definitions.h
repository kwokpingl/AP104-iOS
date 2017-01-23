//
//  Definitions.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#ifndef Definitions_h
#define Definitions_h

// MARK: SERVER_BASIC
#define BASE_URL                @"http://activeaging.xp3.biz"
#define LOGIN_URL               [BASE_URL stringByAppendingPathComponent:@"php/login.php"]
#define DATA_KEY                @"data"

// MARK: SEND_PICTURE_URL
#define UPLOAD_PIC_URL          [BASE_URL stringByAppendingPathComponent:@"php/uploadImage.php"]


// MARK: EVENTS_URL
#define EVENTS_REGISTER_URL          [BASE_URL stringByAppendingPathComponent:@"php/eventRegistration.php"]
#define USER_EVENT_FETCH @"fetch"
#define USER_EVENT_JOIN @"join"
#define USER_EVENT_QUIT @"quit"


// MARK: KEYCHAIN_ITEM
#define keyAttrLabel        @"ActiveAging Login"
#define keyAttrDescription  @"This is your login password for Acitve Aging"
#define keyAttrService      @"biz.xp3.activeaging_test5"



// MARK: USER
#define AUTHORIZATION_KEY       @"authorization"
#define USER_ID_KEY             @"user_ID"
#define USER_NAME_KEY           @"userName"
#define USER_PASSWORD_KEY       @"userPassword"
#define USER_PHONENUMBER_KEY    @"userPhoneNumber"
#define ACTION_KEY              @"action"
#define ACTION_CHECK        @"checkAvailability"
#define ACTION_ADD          @"create"
#define ACTION_GET_ID       @"getID"

// MARK: EVENT
#define EVENT_ID_KEY            @"event_ID"
#define EVENT_TITLE_KEY         @"event_title"
#define EVENT_DESCRIPTION_KEY   @"event_description"
#define EVENT_REG_BEGIN_KEY     @"event_registerBeginDateTime"
#define EVENT_REG_END_KEY       @"event_registerEndDateTime"
#define EVENT_CITY_KEY          @"event_city"
#define EVENT_ADDRESS_KEY       @"evnet_address"
#define EVENT_LON_KEY           @"event_Lon"
#define EVENT_LAT_KEY           @"event_Lat"
#define EVENT_ORGN_NAME_KEY     @"event_organizer_name"
#define EVENT_ORGN_PHONE_KEY    @"event_organizer_phoneNumber"
#define EVENT_ORGN_FAX_KEY      @"event_organizer_faxNumber"
#define EVENT_ORGN_CELL_KEY     @"event_organizer_cellNumber"
#define EVENT_ORGN_EMAIL_KEY    @"event_organizer_email"
#define EVENT_ORGNTION_KEY      @"event_organization"
#define EVENT_WEBPAGE_KEY       @"event_webpage"
#define EVENT_PIC_KEY           @"event_pic"

/*
 1	event_ID	
 2	event_title	text
 3	event_description
 4	event_registerBeginDateTime	datetime
 5	event_registerEndDateTime	datetime
 6	event_startingDateTime	datetime
 7	event_endingDateTime	datetime
 8	event_city	text
 9	event_address	text
 10	event_Lon	text
 11	event_Lat	text
 12	event_organizer_name	text
 13	event_organizer_phoneNumber	text
 14	event_organizer_faxNumber	text
 15	event_organizer_cellNumber	text
 16	event_organizer_email	text
 17	event_organization	text
 18	event_webpage	text
 19	event_pic
 */




#endif /* Definitions_h */
