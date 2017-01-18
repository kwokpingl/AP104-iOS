//
//  ServerManager.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "ServerManager.h"
#import "Definitions.h"

static ServerManager * serverMng = nil;

@implementation ServerManager
+ (instancetype) shareInstance{
    if (serverMng == nil){
        serverMng = [ServerManager new];
    }
    return serverMng;
}

#pragma mark - USER_METHODS
- (void) loginAuthorization:(NSString *) authorization
                   UserName:(NSString *) userName
            UserPhoneNumber:(NSString *) userPhoneNumber
                     Action:(NSString *) action{
    
    // 1. Setup all variables to be sent and receive, as well as the Data to be sent
    NSError * error;
    NSDictionary * jsonObj = @{USER_NAME_KEY:userName,USER_PHONENUMBER:userPhoneNumber,ACTION:action};
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString * finalString = [DATA_KEY stringByAppendingString:[NSString stringWithFormat:@"= %@",jsonString]];
    
    // 2. Setup Network Configuration
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:@{@"Authorization":authorization}];
    /*
     <?php
     // Replace XXXXXX_XXXX with the name of the header you need in UPPERCASE
     $headerStringValue = $_SERVER['HTTP_XXXXXX_XXXX'];
     use getallheaders()
     */
    
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    NSURL * url = [NSURL URLWithString:LOGIN_URL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    // 3. Setup REQUEST
    
    request.HTTPBody = [finalString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:@"POST"];
    
    //    dispatch_group_t group = dispatch_group_create();
    
    //    dispatch_group_enter(group);
    NSURLSessionDataTask * postTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSMutableDictionary * dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
        if ([dataDic[@"result"] boolValue]){
            NSLog( @"Message: %@", dataDic[@"message"]);
        } else{
            NSLog(@"Error: %@", dataDic[@"error"]);
        }
        
        if (!dataDic){
            NSLog(@"error:%@", error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!dataDic){
                _passed = false;
                _message = @"error";
            }else{
                _passed = [dataDic[@"result"] boolValue];
                if (_passed){
                    _message = dataDic[@"message"];
                }else{
                    _message = dataDic[@"error"];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showResult" object:nil];
        });
        
        //        dispatch_group_leave(group);
    }];
    [postTask resume];
    

}


#pragma mark - EVENTS_METHODS


#pragma mark - PUSH_MESSAGE


#pragma mark - PRIVATE_METHOD
- (void) sendURL: (NSString *) url{
    
}
@end
