//
//  DataManager.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/3.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "DataManager.h"
#import "Reachability.h"

@interface DataManager(){
}

@end

@implementation DataManager

+ (void) prepareDatabase{
    SQLite3DBManager * sqlMgr = [[SQLite3DBManager alloc] initWithDatabaseFilename:MOBILE_DATABASE];
    
    // DROP tables
    NSString * query = [NSString stringWithFormat:@"drop table %@",CONTACT_LIST_TABLE];
    [sqlMgr executeQuery:query];
    
    query = [NSString stringWithFormat:@"drop table %@",GROUP_LIST_TABLE];
    [sqlMgr executeQuery:query];
    
    
//    query = [NSString stringWithFormat:@"drop table %@",EMERGENCY_TABLE];
//    [sqlMgr executeQuery:query];
    
    // Create tables
    // FOR CONTACTS
    query = [NSString stringWithFormat: @"create table %@ (%@ int, %@ int, %@ text, %@ text, %@ text, %@ text, %@ text, %@ int, primary key(%@, %@))",CONTACT_LIST_TABLE, GROUP_ID_KEY, USER_ID_KEY, USER_NAME_KEY, USER_CUR_LAT_KEY, USER_CUR_LON_KEY, USER_PHONENUMBER_KEY, USER_PIC_KEY, USER_ROLE_KEY, GROUP_ID_KEY, USER_ID_KEY];
    [sqlMgr executeQuery:query];
    
    // FOR GROUPS
    query = [NSString stringWithFormat:@"create table %@ (%@ int primary key,%@ text,%@ int)", GROUP_LIST_TABLE, GROUP_ID_KEY, GROUP_NAME_KEY, USER_ROLE_KEY];
    [sqlMgr executeQuery:query];
    
    
    
    // FOR EMERGENCY CONTACTS
    query = [NSString stringWithFormat:@"create table %@ (%@ text primary key, %@ text, %@ text, %@ text)",EMERGENCY_TABLE, USER_ID_KEY, USER_NAME_KEY, USER_PHONENUMBER_KEY, USER_PIC_KEY];
    [sqlMgr executeQuery:query];
}

#pragma mark - UPDATE
+ (void) updateContactDatabase: (UpdateSuccess) done{
    ServerManager * serverMgr = [ServerManager shareInstance];
    UserInfo * userInfo = [UserInfo shareInstance];
    SQLite3DBManager * sqlMgr = [[SQLite3DBManager alloc] initWithDatabaseFilename:MOBILE_DATABASE];
    
    
    [serverMgr retrieveGroupInfo:userInfo.getUserID completion:^(NSError *error, id result) {
        if ([result[ECHO_RESULT_KEY] boolValue]){
            
            NSArray * groupArray = result[ECHO_MESSAGE_KEY][@"groups"];
            NSArray * contactArray = result[ECHO_MESSAGE_KEY][@"members"];
            
            for (int i = 0; i<groupArray.count; i++){
                NSInteger groupID = [groupArray[i][GROUP_ID_KEY] integerValue];
                NSString * groupName = groupArray[i][GROUP_NAME_KEY];
                NSInteger role = [groupArray[i][USER_ROLE_KEY] integerValue];
                NSString * query = [NSString stringWithFormat: @"insert into `%@` values ('%ld','%@','%ld')", GROUP_LIST_TABLE, groupID, groupName, role];
                [sqlMgr executeQuery:query];
            }
            
            for (int i = 0; i <contactArray.count; i++){
                NSInteger groupID = [contactArray[i][GROUP_ID_KEY] integerValue];
                NSInteger userID = [contactArray[i][USER_ID_KEY] integerValue];
                NSInteger userRole = [contactArray[i][USER_ROLE_KEY] integerValue];
                NSString * userName = contactArray[i][USER_NAME_KEY];
                NSString * userLat = contactArray[i][USER_CUR_LAT_KEY];
                NSString * userLon = contactArray[i][USER_CUR_LON_KEY];
                NSString * userPhone = contactArray[i][USER_PHONENUMBER_KEY];
                NSString * userPic = contactArray[i][USER_PIC_KEY];
                NSString * query = [NSString stringWithFormat: @"insert into %@ values ('%ld','%ld','%@','%@','%@','%@','%@', '%ld')", CONTACT_LIST_TABLE, groupID,userID, userName,userLat,userLon, userPhone, userPic, userRole];
                [sqlMgr executeQuery:query];
            }
            NSLog(@"SUCCESS");
            done(true);
        }
        else{
            NSLog(@"Error: %@", result[ECHO_ERROR_KEY]);
            done(false);
        }
    }];
}

+ (void) updateEventDatabase {
    ServerManager * serverMgr = [ServerManager shareInstance];
    UserInfo * userInfo = [UserInfo shareInstance];
    SQLite3DBManager * sqlMgr = [[SQLite3DBManager alloc] initWithDatabaseFilename:MOBILE_DATABASE];
    
    NSString * query = [NSString stringWithFormat:@"drop table %@", EVENT_LIST_TABLE];
    [sqlMgr executeQuery:query];
    // FOR EVENTS
    query = [NSString stringWithFormat:@"create table %@ (%@ int primary key, %@ text, %@ text, %@ text, %@ text, %@ text)", EVENT_LIST_TABLE, EVENT_ID_KEY, EVENT_TITLE_KEY, EVENT_LAT_KEY, EVENT_LON_KEY, EVENT_ORGN_PHONE_KEY, EVENT_PIC_KEY];
    [sqlMgr executeQuery:query];
    
    [serverMgr retrieveEventInfo:USER_EVENT_FETCH UserID: userInfo.getUserID  EventID:@"-1" completion:^(NSError *error, id result) {
        if ([result[ECHO_RESULT_KEY] boolValue]){
            NSArray * joinedEvents = result[ECHO_MESSAGE_KEY][@"joined"];
            
            for (int i = 0; i < joinedEvents.count; i++){
                NSInteger eventID = [joinedEvents[i][EVENT_ID_KEY] integerValue];
                NSString * eventTitle = joinedEvents[i][EVENT_TITLE_KEY];
                NSString * eventLat = joinedEvents[i][EVENT_LAT_KEY];
                NSString * eventLon = joinedEvents[i][EVENT_LON_KEY];
                NSString * organizationPhone = joinedEvents[i][EVENT_ORGN_PHONE_KEY];
                NSString * eventImage = joinedEvents[i][EVENT_PIC_KEY];
                NSString * query = [NSString stringWithFormat:@"insert into %@ values ('%ld','%@', '%@', '%@', '%@', '%@')",EVENT_LIST_TABLE, eventID, eventTitle, eventLat, eventLon, organizationPhone, eventImage];
                [sqlMgr executeQuery:query];
            }
            
            NSLog(@"EVENT_LIST SUCCESS");
        }
        else
        {
            NSLog(@"ERROR: %@", result[ECHO_ERROR_KEY]);
        }
    }];
}

+ (void) updateEmergencyDatabaseWithAction: (NSString *) action andDataDic:(NSDictionary *) dic{
    SQLite3DBManager * sqlMgr = [[SQLite3DBManager alloc] initWithDatabaseFilename:MOBILE_DATABASE];
    
    NSString * query;
    
    if ([action isEqualToString:ACTION_ADD]){
        query = [NSString stringWithFormat:@"insert into %@ values ('%@', '%@', '%@', '%@')", EMERGENCY_TABLE, dic[USER_ID_KEY], dic[USER_NAME_KEY], dic[USER_PHONENUMBER_KEY], dic[USER_PIC_KEY]];
        [sqlMgr executeQuery:query];
    }
    else if ([action isEqualToString:ACTION_DELETE]){
        query = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'", EMERGENCY_TABLE,USER_ID_KEY, dic[USER_ID_KEY]];
        [sqlMgr executeQuery:query];
    }
    else{
        return;
    }
}

#pragma mark - RETRIEVE INFO
/// MARK: with_TABLE_name
+ (NSMutableArray *) fetchDatabaseFromTable: (NSString *) table{
    
    NSString * query = [NSString stringWithFormat:@"select * from %@", table];
    
    return [self getArrayUsingQuery:query];
}

/// MARK: with_USERID
+ (NSMutableArray *) fetchUserInfoFromTableWithUserID: (NSInteger) userID{

    NSString * query;
    NSString * idString;
    
    // You can only search from CONTACT_LIST_TABLE
    
    idString = [NSString stringWithFormat:@"%ld", userID];
    query = [NSString stringWithFormat:@"select * from `%@` where `%@` = '%@'", CONTACT_LIST_TABLE, USER_ID_KEY, idString];
    
    return  [self getArrayUsingQuery:query];
}

/// MARK: with_GROUPID
+ (NSMutableArray *) fetchUserInfoFromTableWithGroupID: (NSInteger) groupID {
    
    NSString * query;
    NSString * idString;
    
    // You can only search from CONTACT_LIST_TABLE
    
    idString = [NSString stringWithFormat:@"%ld", groupID];
    query = [NSString stringWithFormat:@"select * from `%@` where `%@` = '%@'", CONTACT_LIST_TABLE, GROUP_ID_KEY, idString];
    
    return  [self getArrayUsingQuery:query];
}

/// MARK: with_ROLE
+ (NSMutableArray *) fetchGroupsFromTableWithRole: (NSInteger) role {
    
    NSString * query;
    NSString * roleString;
    
    // You can only search from CONTACT_LIST_TABLE
    
    roleString = [NSString stringWithFormat:@"%ld", role];
    query = [NSString stringWithFormat:@"select * from `%@` where `%@` = '%@'", GROUP_LIST_TABLE, USER_ROLE_KEY, roleString];
    
    return  [self getArrayUsingQuery:query];
}

+ (NSMutableArray *) fetchEventsFromTable {
    NSString * query = [NSString stringWithFormat: @"select * from `%@`", EVENT_LIST_TABLE];
    return [self getArrayUsingQuery:query];
}

#pragma mark - PRIVATE METHODs
/// MARK: RETURN_INFO_in_ARRAY
+ (NSMutableArray *) getArrayUsingQuery: (NSString *) query{
    SQLite3DBManager * sqlMgr = [[SQLite3DBManager alloc] initWithDatabaseFilename:MOBILE_DATABASE];
    NSArray * dataFromTable = [sqlMgr loadDataFromDB:query];
    NSArray * columnNames = sqlMgr.arrColumnNames;
    NSMutableArray * dataArray = [NSMutableArray new];
    
    for (int i = 0; i < dataFromTable.count; i++){
        NSMutableDictionary * dataDictionary = [NSMutableDictionary new];
        int counter = 0;
        for (NSString * key in columnNames) {
            [dataDictionary setObject:dataFromTable[i][counter] forKey:key];
            counter ++;
        }
        [dataArray addObject:dataDictionary];
    }
    return dataArray;
}

@end
