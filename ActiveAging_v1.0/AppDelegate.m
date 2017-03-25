//
//  AppDelegate.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 12/26/16.
//  Copyright © 2016 PING. All rights reserved.
//

#import "AppDelegate.h"
#import "Definitions.h"
#import "DataManager.h"
#import "UserInfo.h"
#import "EmergencyViewController.h"

#define SQLITE_FILENAME @"eventsList.sql"
#define EVENTS_TABLE_NAME @"CalendarList"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self registerPushNotification];
    
    NSDictionary * pushNotificationDic = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(pushNotificationDic) {
        [self application:application didReceiveRemoteNotification:pushNotificationDic];
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
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
    
    NSLog(@"BOOL : %d", [[self topViewController] isKindOfClass:[EmergencyViewController class]]);
    
    if ([[self topViewController] isKindOfClass:[EmergencyViewController class]]){
        EmergencyViewController * evc = (EmergencyViewController *)[self topViewController];
        [evc callEmergency];
    }
}

- (UIViewController *)topViewController{
    
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Remove all Cache
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray * paths = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL * targetDocURL = paths.firstObject;
    
    NSError *error;
    NSArray *cacheFiles = [fileManager contentsOfDirectoryAtPath:targetDocURL.path error:&error];
    for (NSString *file in cacheFiles) {
        error = nil;
        [fileManager removeItemAtPath:[targetDocURL.path stringByAppendingPathComponent:file] error:&error];
        /* handle error */
    }
    
}


#pragma mark - ===PUSH NOTIFICATION===
- (void) registerPushNotification {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *finalDeviceToken = deviceToken.description;
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    finalDeviceToken = [finalDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UserInfo shareInstance] setDeviceToken:finalDeviceToken];
    
    NSLog(@"SUCCESS");
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString * finalDeviceToken = @"TESTING";
    [[UserInfo shareInstance] setDeviceToken:finalDeviceToken];
    NSLog(@"DID FAIL TO REGISTER : %@", error.description);
}



- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler {
    
    
    
    
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    // When app is running foreground
    // Seems like this method is needed for the APP not crash when INACTIVE
    // is called when the OS receives a RemoteNotification and the app is running (in the background/suspended or in the foreground.)
}


/*
 Use this method to process incoming remote notifications for your app. Unlike the application:didReceiveRemoteNotification: method, which is called only when your app is running in the foreground, the system calls this method when your app is running in the foreground or background.
 */
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // When push notification is pressed, it will enter this part
    // When APP is INACTIVE
    
}

@end
