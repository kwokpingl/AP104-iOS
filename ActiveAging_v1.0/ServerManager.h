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

- (void) loginAuthorization:(NSString *) authorization
                   UserName:(NSString *) userName
            UserPhoneNumber:(NSString *) userPhoneNumber
                     Action: (NSString *) action
                 completion:(DoneHandler) done;

- (void) uploadPictureWithData: (NSData *) data
                 Authorization:(NSString *) authorization
                      UserName: (NSString *)userName

               UserPhoneNumber: (NSString *) userPhoneNumber
                    completion: (DoneHandler) done;

- (void) retrieveEventInfo: (NSString *) action
                    UserID: (NSString *) userID
                   EventID: (NSString *) eventID
                completion:(DoneHandler) done;


@end
