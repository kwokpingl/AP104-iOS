//
//  ImageManager.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/3.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ServerManager.h"
#import "SQLite3DBManager.h"
#import "UserInfo.h"

@interface ImageManager : NSObject

+ (void) getUserImage: (NSInteger) userID
           completion:(DoneHandler) done;
+ (void) getEventImage: (NSString *) eventImageName
            completion:(DoneHandler) done;
+ (UIImage *) loadImageWithFileName: (NSString *) fileName;
+ (void) saveImageWithFileName: (NSString *)imageFileName ImageData:(NSData *) imageData;
@end
