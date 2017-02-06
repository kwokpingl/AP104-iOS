//
//  DataManager.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/3.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "DataManager.h"


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
    query = [NSString stringWithFormat: @"create table %@ (%@ int, %@ int, %@ text, %@ text, %@ text, %@ text, %@ text, primary key(%@, %@))",CONTACT_LIST_TABLE,GROUP_ID_KEY, USER_ID_KEY, USER_NAME_KEY, USER_CUR_LAT_KEY, USER_CUR_LON_KEY, USER_PHONENUMBER_KEY, USER_PIC_KEY, GROUP_ID_KEY, USER_ID_KEY];
    [sqlMgr executeQuery:query];
    
    // FOR GROUPS
    query = [NSString stringWithFormat:@"create table %@ (%@ int primary key,%@ text,%@ int)", GROUP_LIST_TABLE, GROUP_ID_KEY, GROUP_NAME_KEY, USER_ROLE_KEY];
    [sqlMgr executeQuery:query];
    
    // FOR EMERGENCY CONTACTS
    query = [NSString stringWithFormat:@"create table %@ (%@ integer primary key autoincrement, %@ text, %@ text)",EMERGENCY_TABLE, USER_ID_KEY, USER_NAME_KEY, USER_PHONENUMBER_KEY];
    [sqlMgr executeQuery:query];
}

+ (void) updateContactDatabase{
    ServerManager * serverMgr = [ServerManager shareInstance];
    UserInfo * userInfo = [UserInfo shareInstance];
    SQLite3DBManager * sqlMgr = [[SQLite3DBManager alloc] initWithDatabaseFilename:MOBILE_DATABASE];
    
    
    [serverMgr retrieveGroupInfo:userInfo.getUserID completion:^(NSError *error, id result) {
        if ([result[ECHO_RESULT_KEY] boolValue]){
            NSLog(@"UPDATE DB SUCCESS: %@",result[ECHO_MESSAGE_KEY]);
            
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
                NSString * userName = contactArray[i][USER_NAME_KEY];
                NSString * userLat = contactArray[i][USER_CUR_LAT_KEY];
                NSString * userLon = contactArray[i][USER_CUR_LON_KEY];
                NSString * userPhone = contactArray[i][USER_PHONENUMBER_KEY];
                NSString * userPic = contactArray[i][USER_PIC_KEY];
                NSString * query = [NSString stringWithFormat: @"insert into %@ values ('%ld','%ld','%@','%@','%@','%@','%@')", CONTACT_LIST_TABLE, groupID,userID, userName,userLat,userLon, userPhone, userPic];
                [sqlMgr executeQuery:query];
            }
            NSLog(@"SUCCESS");
            
        }
        else{
            NSLog(@"Error: %@", result[ECHO_ERROR_KEY]);
        }
    }];
}


+ (NSMutableArray *) fetchDatabaseFromTable: (NSString *) table{
    
    NSString * query = [NSString stringWithFormat:@"select * from %@", table];
    
    return [self getArrayUsingQuery:query];

}


+ (NSMutableArray *) fetchUserInfoFromTableWithUserID: (NSInteger) userID{

    NSString * query;
    NSString * idString;
    
    // You can only search from CONTACT_LIST_TABLE
    
    idString = [NSString stringWithFormat:@"%ld", userID];
    query = [NSString stringWithFormat:@"select * from `%@` where `%@` = '%@'", CONTACT_LIST_TABLE, USER_ID_KEY, idString];
    
    return  [self getArrayUsingQuery:query];
}

+ (NSMutableArray *) fetchUserInfoFromTableWithGroupID: (NSInteger) groupID {
    
    NSString * query;
    NSString * idString;
    
    // You can only search from CONTACT_LIST_TABLE
    
    idString = [NSString stringWithFormat:@"%ld", groupID];
    query = [NSString stringWithFormat:@"select * from `%@` where `%@` = '%@'", CONTACT_LIST_TABLE, GROUP_ID_KEY, idString];
    
    return  [self getArrayUsingQuery:query];
}

+ (NSMutableArray *) fetchGroupsFromTableWithRole: (NSInteger) role {
    
    NSString * query;
    NSString * roleString;
    
    // You can only search from CONTACT_LIST_TABLE
    
    roleString = [NSString stringWithFormat:@"%ld", role];
    query = [NSString stringWithFormat:@"select * from `%@` where `%@` = '%@'", GROUP_LIST_TABLE, USER_ROLE_KEY, roleString];
    
    return  [self getArrayUsingQuery:query];
}

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
