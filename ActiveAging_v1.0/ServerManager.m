//
//  ServerManager.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "ServerManager.h"
#import <AFNetworking.h>
#import "UserInfo.h"

static ServerManager * serverMgr = nil;

@implementation ServerManager
{
    UserInfo * _userInfo;
}
+ (instancetype) shareInstance{
    if (serverMgr == nil){
        serverMgr = [ServerManager new];
    }
    return serverMgr;
}


#pragma mark - USER_METHODS_AFN
/// MARK: LOGIN_METHOD
- (void) loginAuthorization:(NSString *)authorization UserName:(NSString *)userName UserPhoneNumber:(NSString *)userPhoneNumber Action: (NSString *) action completion: (DoneHandler) done{
    NSDictionary * jsonObj = @{AUTHORIZATION_KEY: authorization,
                               USER_NAME_KEY:userName,
                               USER_PHONENUMBER_KEY:userPhoneNumber,
                               ACTION_KEY:action};
    [self doPost:LOGIN_URL
      parameters:jsonObj
      completion:done];
    
}


/// MARK: UPLOAD_PICTURE
- (void) uploadPictureWithData: (NSData *) data
                 Authorization: (NSString *) authorization
                      UserName:(NSString *) userName
               UserPhoneNumber:(NSString *)userPhoneNumber
                    completion:(DoneHandler)done
{
    
    NSDictionary * jsonObj = @{AUTHORIZATION_KEY: authorization,
                               USER_NAME_KEY: userName,
                               USER_PHONENUMBER_KEY: userPhoneNumber};
    

    [self doPost:UPLOAD_PIC_URL
      parameters:jsonObj
            data:data
      completion:done];
    
}

- (void) updateToken: (NSString *) token completion:(DoneHandler) done {
    
    NSDictionary * jsonObj = @{USER_ID_KEY: @([UserInfo shareInstance].getUserID),
                               USER_TOKEN_KEY: [UserInfo shareInstance].getDeviceToken};
    
    [self doPost:UPDATE_TOKEN_URL
      parameters:jsonObj
      completion:done];
}

/// MARK: UPDATE_LOCATION
- (void) updateLocationForAuthorization:    (NSString *) authorization
                                 andLat:    (NSString *) lat
                                 andLon:    (NSString *) lon
                             completion:    (DoneHandler) done
{
    _userInfo = [UserInfo shareInstance];
    
    NSDictionary * jsonObj = @{AUTHORIZATION_KEY: authorization,
                               USER_NAME_KEY: _userInfo.getUsername,
                               USER_PHONENUMBER_KEY:  _userInfo.getPassword,
                               USER_CUR_LAT_KEY: lat,
                               USER_CUR_LON_KEY: lon,
                               ACTION_KEY: ACTION_UPDATELOCATION,
                               USER_ID_KEY: @(_userInfo.getUserID)};
    [self doPost:LOGIN_URL
      parameters:jsonObj
      completion:done];
}

- (void) updateUserNameForAuthorization: (NSString *) authorization
                             completion: (DoneHandler) done{
    _userInfo = [UserInfo shareInstance];
    
    NSDictionary * jsonObj = @{AUTHORIZATION_KEY: authorization,
                               USER_NAME_KEY: _userInfo.getUsername,
                               ACTION_KEY: ACTION_UPDATENAME,
                               USER_ID_KEY: @(_userInfo.getUserID),
                               USER_PHONENUMBER_KEY: _userInfo.getPassword};
    [self doPost:LOGIN_URL
      parameters:jsonObj
      completion:done];
}

- (void) updateUserGroupsWithAction: (NSString *) action
                           dataInfo: (NSDictionary *) data
                         completion:(DoneHandler) done{
    
    NSDictionary * jsonObj;
    
    if ([action isEqualToString:GROUP_ACTION_CREATE]){
        jsonObj = @{ACTION_KEY: action,
                    USER_ID_KEY: data[USER_ID_KEY],
                    GROUP_NAME_KEY: data[GROUP_NAME_KEY]
                    };
    }
    else if ([action isEqualToString:GROUP_ACTION_DROPMEMBER]){
        jsonObj = @{ACTION_KEY: action,
                    USER_ID_KEY: data[USER_ID_KEY],
                    GROUP_ID_KEY: data[GROUP_ID_KEY],
                    GROUP_MEMBER_KEY: data[GROUP_MEMBER_KEY]
                    };
    }
    else if ([action isEqualToString:GROUP_ACTION_DROP]){
        jsonObj = @{ACTION_KEY: action,
                    USER_ID_KEY: data[USER_ID_KEY],
                    GROUP_ID_KEY: data[GROUP_ID_KEY],
                    };
    }
    else if ([action isEqualToString:GROUP_ACTION_UPDATENAME]){
        jsonObj = @{ACTION_KEY: action,
                    USER_ID_KEY: data[USER_ID_KEY],
                    GROUP_NAME_KEY: data[GROUP_NAME_KEY],
                    GROUP_ID_KEY: data[GROUP_ID_KEY]};
    }
    else if ([action isEqualToString:GROUP_ACTION_UPDATEROLE]){
        jsonObj = @{ACTION_KEY: action,
                    USER_ID_KEY: data[USER_ID_KEY],
                    GROUP_ID_KEY: data[GROUP_ID_KEY]};
    }
    [self doPost:USER_GROUP_URL
      parameters:jsonObj
      completion:done];
    
}

/*
 $senderID = $inputArray["user_ID"];
 $senderName = $inputArray["userName"];
 $groupName = $inputArray["group_name"];
 $groupID = $inputArray["group_ID"];
 $receiverPhoneNumber = $inputArray["userPhoneNumber"];
 $action = $inputArray["action"];
 */


- (void) sendInvitationFor: (NSString *) receiverPhoneNumber ToGroupID: (NSInteger) groupID withAction: (NSString *) action completion: (DoneHandler) done{
    
    NSDictionary * jsonObj = @{USER_ID_KEY: @([UserInfo shareInstance].getUserID),
                               USER_NAME_KEY: [UserInfo shareInstance].getUsername,
                               USER_PHONENUMBER_KEY: receiverPhoneNumber,
                               GROUP_ID_KEY: @(groupID),
                               ACTION_KEY: action};
    
    [self doPost:SEND_PUSH_URL
      parameters:jsonObj
      completion:done];
}

/// MARK: RETRIEVE_GROUPS
- (void) retrieveGroupInfo: (NSInteger )userID completion:(DoneHandler) done{
    NSDictionary * jsonObj = @{USER_ID_KEY: @(userID),
                               ACTION_KEY:GROUP_ACTION_FETCH};
    
    [self doPost:USER_GROUP_URL
      parameters:jsonObj
      completion:done];
}

- (void) addGroupMember{}


/// MARK: RETRIEVE_EVENTS
- (void) retrieveEventInfo:(NSString *)action
                    UserID:(NSInteger )userID
                   EventID:(NSString *)eventID
                completion:(DoneHandler)done{
    
    NSInteger num_EventID = [eventID integerValue];

    
    NSDictionary * jsonObj = @{USER_ID_KEY: @(userID),
                               EVENT_ID_KEY:@(num_EventID),
                               ACTION_KEY: action
                               };
    
    [self doPost:EVENTS_REGISTER_URL
      parameters:jsonObj
      completion:done];
}


- (void) fetchVerificationCodeForPhoneNumber: (NSString *) userPhoneNumber Action:(NSString *)action Code: (NSString *) code completion:(DoneHandler)done{
    
    // this will need USER_PHONENUMBER and USERNAME
    NSDictionary * jsonObj = @{USER_PHONENUMBER_KEY: userPhoneNumber, ACTION_KEY: action, VERIFICATION_KEY: code};
    
    [self doPost:VERIFICATION_CODE_URL
      parameters:jsonObj
      completion:done];
}

/// MARK: DOWNLOAD_PICTURE_FROM_SERVER
- (void) downloadPictureWithImgFileName: (NSString *) imgFileName
                                FromURL: (NSString *) fileURL
                          completion: (DoneHandler) done{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"image/jpeg"];
    
    if([imgFileName isKindOfClass:[NSNull class]] || [imgFileName isEqualToString:@"<null>"]){
        imgFileName = @"default.jpg";
    }
    
    NSString * imageURLString = [fileURL stringByAppendingPathComponent:imgFileName];
    [manager GET:imageURLString
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             done(nil,responseObject);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             done(error,nil);
         }];
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
                     
                     NSLog(@"SUCCESS: %@", responseObject);
                     done(nil,responseObject);
                     
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     
                     NSLog(@"ERROR: %@", error);
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
