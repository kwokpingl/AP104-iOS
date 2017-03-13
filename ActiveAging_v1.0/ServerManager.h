//
//  ServerManager.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definitions.h"

typedef void (^DoneHandler)(NSError *error,id result);
//typedef void (^DICTIONARY_RETRIEVER)(NSMutableDictionary* dict);

@interface ServerManager : NSObject
@property (nonatomic, strong) NSString * message;
@property (nonatomic) BOOL passed;


+ (instancetype) shareInstance;


- (void) uploadPictureWithData: (NSData *) data
                 Authorization: (NSString *) authorization
                      UserName: (NSString *)userName
               UserPhoneNumber: (NSString *) userPhoneNumber
                    completion: (DoneHandler) done;

- (void) updateLocationForAuthorization: (NSString *) authorization
                                 andLat: (NSString *) lat
                                 andLon: (NSString *) lon
                             completion: (DoneHandler) done;

- (void) updateUserNameForAuthorization: (NSString *) authorization
                             completion: (DoneHandler) done;

- (void) updateUserGroupsWithAction: (NSString *) action
                                 dataInfo: (NSDictionary *) data
                               completion: (DoneHandler) done;

- (void) updateToken: (NSString *) token
          completion:(DoneHandler) done;

- (void) sendInvitationFor: (NSString *) receiverPhoneNumber
                 ToGroupID: (NSInteger) groupID
                withAction: (NSString *) action
                completion: (DoneHandler) done;

- (void) retrieveEventInfo: (NSString *) action
                    UserID: (NSInteger ) userID
                   EventID: (NSString *) eventID
                completion:(DoneHandler) done;

- (void) downloadPictureWithImgFileName: (NSString *) imgFileName
                                FromURL: (NSString *) fileURL
                             completion: (DoneHandler) done;



#pragma mark - REGISTER/LOGIN
- (void) fetchVerificationCodeForPhoneNumber: (NSString *) userPhoneNumber Action: (NSString *) action Code:(NSString *) code completion:(DoneHandler) done;

- (void) loginAuthorization:(NSString *) authorization
                   UserName:(NSString *) userName
            UserPhoneNumber:(NSString *) userPhoneNumber
                     Action: (NSString *) action
                 completion:(DoneHandler) done;

#pragma mark - GROUP
- (void) retrieveGroupInfo: (NSInteger ) userID
                completion:(DoneHandler) done;

@end
