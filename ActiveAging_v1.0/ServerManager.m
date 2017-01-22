//
//  ServerManager.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "ServerManager.h"
#import <AFNetworking.h>

static ServerManager * serverMng = nil;

@implementation ServerManager
+ (instancetype) shareInstance{
    if (serverMng == nil){
        serverMng = [ServerManager new];
    }
    return serverMng;
}


#pragma mark - USER_METHODS_AFN
// MARK: LOGIN_METHOD
- (void) loginAuthorization:(NSString *)authorization UserName:(NSString *)userName UserPhoneNumber:(NSString *)userPhoneNumber Action: (NSString *) action completion: (DoneHandler) done{
    NSDictionary * jsonObj = @{AUTHORIZATION_KEY: authorization,
                               USER_NAME_KEY:userName,
                               USER_PHONENUMBER_KEY:userPhoneNumber,
                               ACTION_KEY:action};
    [self doPost:LOGIN_URL
      parameters:jsonObj
      completion:done];
    
}


// MARK: UPLOAD_PICTURE
- (void) uploadPictureWithData: (NSData *) data Authorization:
(NSString *) authorization
UserName:(NSString *) userName
UserPhoneNumber:(NSString *)userPhoneNumber
completion:(DoneHandler)done{
    NSDictionary * jsonObj = @{AUTHORIZATION_KEY: authorization,
                               USER_NAME_KEY: userName,
                               USER_PHONENUMBER_KEY: userPhoneNumber};
    

    [self doPost:UPLOAD_PIC_URL
      parameters:jsonObj
            data:data
      completion:done];
    
}


// MARK: RETRIEVE_USERINFO



// MARK: RETRIEVE_EVENTS
- (void) retrieveEventInfo:(NSString *)action
                    UserID:(NSInteger )userID
                   EventID:(NSString *)eventID
                completion:(DoneHandler)done{
    NSDictionary * jsonObj = @{USER_ID_KEY: @(userID),
                               EVENT_ID_KEY:eventID,
                               ACTION_KEY: action
                               };
    
    [self doPost:EVENTS_REGISTER_URL parameters:jsonObj completion:done];
}


#pragma mark - PRIVATE_METHODS

// MARK: DO_POST
- (void) doPost:(NSString*) urlString
     parameters:(NSDictionary*)parameters
     completion:(DoneHandler) done{
    AFHTTPSessionManager * sessionManager = [AFHTTPSessionManager manager];
    
    
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary * finalParameter = @{DATA_KEY: jsonString};
    
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    
    [sessionManager POST:urlString
              parameters:finalParameter
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     
                     NSLog(@"SUCCESS LOGIN: %@", responseObject);
                     done(nil,responseObject);
                     
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     
                     NSLog(@"ERROR LOGIN: %@", error);
                     done(error, nil);
                 }];
}

// MARK: DO_POST_WITH_DATA
- (void) doPost:(NSString*) urlString
     parameters:(NSDictionary*)parameters
           data: (NSData *) data
     completion:(DoneHandler) done{
    
    AFHTTPSessionManager * sessionManager = [AFHTTPSessionManager manager];
    
    NSData * jsonData = [NSJSONSerialization
                         dataWithJSONObject:parameters
                         options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString * jsonStr = [[NSString alloc]
                          initWithData:jsonData
                          encoding:NSUTF8StringEncoding];
    
    NSDictionary * finalDic = @{DATA_KEY: jsonStr};
    
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    // now set the picture
    [sessionManager POST:UPLOAD_PIC_URL
              parameters:finalDic
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data
                                    name:@"photoToUpload"
                                fileName:@"profile.jpg"
                                mimeType:@"image/jpg"];
}
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task,
                           id  _Nullable responseObject) {
                     
                     NSLog(@"UPLOAD PHOTO SUCCESS: %@", responseObject);
                     done(nil, responseObject);
        
                 }
                 failure:^(NSURLSessionDataTask * _Nullable task,
                           NSError * _Nonnull error) {
                     
                     NSLog(@"ERR_UPLOAD PHOTO FAILED: %@", error);
                     done (error, nil);
    }];
    
}

#pragma mark - STILL_WORKING_ON
// MARK: RETRIEVE_INFO
//- (NSDictionary *) retrieveInfo:(NSInteger) userID {
//    
//}

// MARK: DELETE_ACCOUNT





#pragma mark - USER_METHODS
//- (void) loginAuthorization:(NSString *) authorization
//                   UserName:(NSString *) userName
//            UserPhoneNumber:(NSString *) userPhoneNumber
//                     Action:(NSString *) action{
//    
//    // 1. Setup all variables to be sent and receive, as well as the Data to be sent
//    NSError * error;
//    NSDictionary * jsonObj = @{USER_NAME_KEY:userName,USER_PHONENUMBER:userPhoneNumber,ACTION:action};
//    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:&error];
//    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSString * finalString = [DATA_KEY stringByAppendingString:[NSString stringWithFormat:@"= %@",jsonString]];
//    
//    // 2. Setup Network Configuration
//    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    [config setHTTPAdditionalHeaders:@{@"Authorization":authorization}];
//    /*
//     <?php
//     // Replace XXXXXX_XXXX with the name of the header you need in UPPERCASE
//     $headerStringValue = $_SERVER['HTTP_XXXXXX_XXXX'];
//     use getallheaders()
//     */
//    
//    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
//    NSURL * url = [NSURL URLWithString:LOGIN_URL];
//    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
//    
//    // 3. Setup REQUEST
//    
//    request.HTTPBody = [finalString dataUsingEncoding:NSUTF8StringEncoding];
//    [request setHTTPMethod:@"POST"];
//    
//    //    dispatch_group_t group = dispatch_group_create();
//    
//    //    dispatch_group_enter(group);
//    NSURLSessionDataTask * postTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        NSMutableDictionary * dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
//        if ([dataDic[@"result"] boolValue]){
//            NSLog( @"Message: %@", dataDic[@"message"]);
//        } else{
//            NSLog(@"Error: %@", dataDic[@"error"]);
//        }
//        
//        if (!dataDic){
//            NSLog(@"error:%@", error);
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (!dataDic){
//                _passed = false;
//                _message = @"error";
//            }else{
//                _passed = [dataDic[@"result"] boolValue];
//                if (_passed){
//                    _message = dataDic[@"message"];
//                }else{
//                    _message = dataDic[@"error"];
//                }
//            }
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"showResult" object:nil];
//        });
//        
//        //        dispatch_group_leave(group);
//    }];
//    [postTask resume];
//    
//
//}
//

#pragma mark - EVENTS_METHODS


#pragma mark - PUSH_MESSAGE


@end
