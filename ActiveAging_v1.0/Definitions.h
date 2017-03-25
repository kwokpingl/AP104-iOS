//
//  Definitions.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#ifndef Definitions_h
#define Definitions_h


#define WIDGET_NAME @"group.ActiveAging.TodayExtensionWidgetSharingDefaults"

#pragma mark - === URLs ===
/// MARK: SERVER_BASIC

#define BASE_HOST       @"192.168.43.109/"
#define BASE_URL        @"http://192.168.43.109/ActiveAging"
/// MARK: EVENTS_URL
#define EVENTS_REGISTER_URL     [BASE_URL stringByAppendingPathComponent:@"php/eventRegistration.php"]
/// MARK: VERIFICATION_CODE_URL
#define VERIFICATION_CODE_URL   [BASE_URL stringByAppendingPathComponent:@"php/verificationCode.php"]
/// MARK: UPDATE TOKEN
#define UPDATE_TOKEN_URL        [BASE_URL stringByAppendingPathComponent:@"php/updateDeviceToken.php"]
/// MARK: USERGROUPS_URL
#define USER_GROUP_URL          [BASE_URL stringByAppendingPathComponent:@"php/userGroups.php"]
/// MARK: PICTURE_URL
#define UPLOAD_PIC_URL          [BASE_URL stringByAppendingPathComponent:@"php/uploadImage.php"]
#define EVENT_PIC_URL           [BASE_URL stringByAppendingPathComponent:@"pic/eventPic"]
/// MARK: SEND INVITATION
#define SEND_PUSH_URL           [BASE_URL stringByAppendingPathComponent:@"php/sendInvitation.php"]
/// MARK: PICTURE URL
#define USER_PIC_URL            [BASE_URL stringByAppendingPathComponent:@"pic/userPic"]
/// MARK: USER_ID URL
#define LOGIN_URL               [BASE_URL stringByAppendingPathComponent:@"php/login.php"]
#define TEST_URL                [BASE_URL stringByAppendingPathComponent:@"php/test.php"]


#pragma mark - === KEYS ===
/// MARK: COMMON_KEYS
#define ACTION_KEY              @"action"
#define DATA_KEY                @"data"
/// MARK: ECHO_KEYS
#define ECHO_RESULT_KEY         @"result"
#define ECHO_MESSAGE_KEY        @"message"
#define ECHO_ERROR_KEY          @"error"
/// MARK: USER_KEYS
#define AUTHORIZATION_KEY       @"authorization"
#define VERIFICATION_KEY        @"validationCode"
#define USER_CUR_LON_KEY        @"userCurrentLongitude"
#define USER_CUR_LAT_KEY        @"userCurrentLatitude"
#define USER_PHONENUMBER_KEY    @"userPhoneNumber"
#define USER_PASSWORD_KEY       @"userPassword"
#define USER_TOKEN_KEY          @"user_Token"
#define USER_NAME_KEY           @"userName"
#define USER_ID_KEY             @"user_ID"
#define USER_PIC_KEY            @"userPic"

/// MARK: EVENT_KEYS
#define EVENT_ID_KEY            @"event_ID"
    // description 資訊
#define EVENT_TITLE_KEY         @"event_title"
#define EVENT_DESCRIPTION_KEY   @"event_description"
#define EVENT_START_KEY         @"event_startingDateTime"
#define EVENT_END_KEY           @"event_endingDateTime"
    // registration time 報名期間
#define EVENT_REG_BEGIN_KEY     @"event_registerBeginDateTime"
#define EVENT_REG_END_KEY       @"event_registerEndDateTime"
    // address 地址
#define EVENT_CITY_KEY          @"event_city"
#define EVENT_ADDRESS_KEY       @"event_address"
#define EVENT_LON_KEY           @"event_Lon"
#define EVENT_LAT_KEY           @"event_Lat"
    // contact info 聯絡方式
#define EVENT_ORGN_NAME_KEY     @"event_organizer_name"
#define EVENT_ORGN_PHONE_KEY    @"event_organizer_phoneNumber"
#define EVENT_ORGN_FAX_KEY      @"event_organizer_faxNumber"
#define EVENT_ORGN_CELL_KEY     @"event_organizer_cellNumber"
#define EVENT_ORGN_EMAIL_KEY    @"event_organizer_email"
    // organization 舉辦單位
#define EVENT_ORGNTION_KEY      @"event_organization"
#define EVENT_WEBPAGE_KEY       @"event_webpage"
    // pic 圖檔
#define EVENT_PIC_KEY           @"event_pic"
    // for USER
#define USER_EVENT_STATUS_KEY   @"joinedEvents"

/// MARK: AUTHORIZATION
#define USER_AUTHORIZATION  @"user"
#define ORG_AUTHORIZATION   @"organization"


/// MARK: GROUP_KEYS
#define GROUP_ID_KEY        @"group_ID"
#define GROUP_NAME_KEY      @"group_name"
#define GROUP_MEMBER_KEY    @"member_ID"
#define USER_ROLE_KEY       @"role"
#define ROLE_MASTER         @"1"
#define ROLE_PARTICIPANT    @"-1"


#pragma mark - === ACTIONS ===

/// MARK: USER_ACTIONS
#define ACTION_UPDATELOCATION   @"updateLocation"
#define ACTION_UPDATETOKEN      @"updateToken"
#define ACTION_UPDATENAME       @"updateName"
#define ACTION_SENDSMS          @"send SMS"
#define ACTION_GET_ID           @"getID"
#define ACTION_DELETE           @"delete"
#define ACTION_CHECK            @"checkAvailability"
#define ACTION_ADD              @"create"

/// MARK: GROUP_ACTIONS
#define GROUP_ACTION_DROPMEMBER @"dropMember"
#define GROUP_ACTION_ADDMEMBER  @"addMember"
#define GROUP_ACTION_UPDATENAME @"updateName"
#define GROUP_ACTION_UPDATEROLE @"updateRole"
#define GROUP_ACTION_FETCH      @"fetchGroup"
#define GROUP_ACTION_CREATE     @"createGroup"
#define GROUP_ACTION_DROP       @"dropGroup"

/// MARK: EVENT ACTIONS
#define USER_EVENT_FETCH        @"fetch"
#define USER_EVENT_JOIN         @"join"
#define USER_EVENT_QUIT         @"quit"

/// MARK: VERIFICATION ACTION
#define VERIFICATION_ACTION_DELETE @"delete"
#define VERIFICATION_ACTION_SEND   @"send"
#define VERIFICATION_ACTION_CHECK  @"check"

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

#pragma mark - === PHONE DATABASE ===
/// MARK: DB_&_TABLES_&_KEYS
#define MOBILE_DATABASE @"activeaging.sql"

#define CONTACT_LIST_TABLE    @"contactList"
#define GROUP_LIST_TABLE    @"groupList"
#define EVENT_LIST_TABLE    @"eventList"
#define EMERGENCY_TABLE     @"emergencyList"

/// MARK: DB_KEY
#define EMERGENCY_ID_KEY    @"emergency_ID"
#define EMERGENCY_NAME_KEY  @"emergnecy_name"
#define EMERGENCY_PHONE_KEY @"emergencyPhoneNumber"

#pragma mark - === KEYCHAINS ===
/// MARK: KEYCHAIN_ITEM
#define keyAttrLabel        @"ActiveAging Login"
#define keyAttrDescription  @"This is your login password for Acitve Aging"
#define keyAttrService      @"biz.xp3.activeaging_test5"

#define MAXIMUM_EMERGENCY_GROUP 5
#define MAXIMUM_PERSONAL_GROUP 3
#define MAXIMUM_MEMBER_PER_GROUP 20

/// MARK: LOGIN_PAGE
#define PHONE_NUMBER_REX @"[0][9][0-9]{8}"
#define PHONE_NUMBER_LENGTH 10
#define NAME_REX @"[a-zA-Z\u4e00-\u9fa5]+"
#define GROUP_NAME_REX @"[0-9a-zA-Z\u4e00-\u9fa5 ]+"


/// MARK: CLLocation
#define DISTANCE_FILTER 10

/// MARK: DATE_FORMAT
#define DATE_FORMAT @"YYYY-MM-dd HH:mm:ss"

/// MARK: USERDEFAULTS
#define SHOULD_SHARE_LOCATION_KEY @"shareLocation"

#endif /* Definitions_h */


