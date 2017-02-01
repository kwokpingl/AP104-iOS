//
//  AppDelegate.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 12/26/16.
//  Copyright © 2016 PING. All rights reserved.
//

#import "AppDelegate.h"
#import "SQLite3DBManager.h"
#import "Definitions.h"

#define SQLITE_FILENAME @"eventsList.sql"
#define EVENTS_TABLE_NAME @"CalendarList"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    SQLite3DBManager * dbManager = [[SQLite3DBManager alloc] initWithDatabaseFilename:SQLITE_FILENAME];
//    
//    NSString * query = [NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement, title text, startDateTime text, endDateTime text, detail text, location text)", EVENTS_TABLE_NAME];
    
//    NSString * query = [NSString stringWithFormat:@"drop table %@", EVENTS_TABLE_NAME];
    
//    [dbManager executeQuery:query];
    
    SQLite3DBManager * _sqlMgr = [[SQLite3DBManager alloc] initWithDatabaseFilename:MOBILE_DATABASE];
    
    // Create tables if not existed
    // FOR CONTACTS
    NSString * query = [NSString stringWithFormat: @"create table %@ (%@ int, %@ int, %@ text, %@ text, %@ text, %@ text, primary key(%@, %@))",CONTACT_LIST_TABLE,GROUP_ID_KEY, USER_ID_KEY, USER_CUR_LAT_KEY, USER_CUR_LON_KEY, USER_PHONENUMBER_KEY, USER_PIC_KEY, GROUP_ID_KEY, USER_ID_KEY];
    [_sqlMgr executeQuery:query];
    
    // FOR GROUPS
    query = [NSString stringWithFormat:@"create table %@ (%@ int primary key,%@ text,%@ int)", GROUP_LIST_TABLE, GROUP_ID_KEY, GROUP_NAME_KEY, USER_ROLE_KEY];
    [_sqlMgr executeQuery:query];
    
    // FOR EMERGENCY CONTACTS
    query = [NSString stringWithFormat:@"create table %@ (%@ int primary key autoincrement, %@ text, %@ text)",EMERGENCY_TABLE, EMERGENCY_ID_KEY, EMERGENCY_NAME_KEY, EMERGENCY_PHONE_KEY];
    [_sqlMgr executeQuery:query];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
