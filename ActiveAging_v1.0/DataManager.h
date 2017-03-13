//
//  DataManager.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/3.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLite3DBManager.h"
#import "ServerManager.h"
#import "UserInfo.h"
#import <UIKit/UIKit.h>

typedef void(^UpdateSuccess)(BOOL done);

@interface DataManager : NSObject

+ (void) prepareDatabase;

+ (void) updateContactDatabase: (UpdateSuccess) done;

+ (void) updateEventDatabase;

+ (void) updateEmergencyDatabaseWithAction: (NSString *) action
                                andDataDic:(NSDictionary *) dic;

+ (NSMutableArray *) fetchDatabaseFromTable: (NSString *) table;

+ (NSMutableArray *) fetchUserInfoFromTableWithUserID: (NSInteger) userID;

+ (NSMutableArray *) fetchUserInfoFromTableWithGroupID: (NSInteger) groupID;

+ (NSMutableArray *) fetchGroupsFromTableWithRole: (NSInteger) role;

+ (NSMutableArray *) fetchEventsFromTable;

@end
