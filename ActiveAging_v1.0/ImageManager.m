//
//  ImageManager.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/3.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "ImageManager.h"


@implementation ImageManager{
}
+ (void) saveImageWithFileName: (NSString *)imageFileName ImageData:(NSData *) imageData{
    
    NSURL * fullTargetURL = [ImageManager getFullURLWithFileName:imageFileName];
    [imageData writeToURL:fullTargetURL atomically:true];
}

+ (void) getUserImage: (NSInteger) userID completion:(DoneHandler) done{
    NSString * imageName = [NSString stringWithFormat:@"%ld_profile.jpg", userID];
    [self getImageFromServer:USER_PIC_URL WithImageName:imageName completion:done];
}


+ (UIImage *) getEventImage: (NSString *) eventImageName {
    
    ServerManager * serverMgr = [ServerManager shareInstance];
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    
    __block NSData * imageData;
    
    [serverMgr downloadPictureWithImgFileName:eventImageName FromURL:EVENT_PIC_URL completion:^(NSError *error, id result) {
        if (error){
            NSLog(@"ERROR IN DOWNLOAD IMAGE: %@", error);
        }else {
            imageData = result;
        }
        dispatch_group_leave(group);
    }];
    dispatch_group_wait(group, DISPATCH_TIME_NOW);
    
    return [UIImage imageWithData:imageData];
}

+ (UIImage *) loadImageWithFileName: (NSString *) fileName{
    fileName = [fileName stringByDeletingPathExtension];
    NSURL * fullTargetURL = [ImageManager getFullURLWithFileName:fileName];
    NSData * data = [NSData dataWithContentsOfURL:fullTargetURL];
    return [UIImage imageWithData:data];
}

+ (NSURL *) getFullURLWithFileName: (NSString *) fileName{
    NSArray * paths = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    
    NSURL * targetDocURL = paths.firstObject;
    NSString * fullFileName = fileName;
    NSURL * finalTargetURL = [targetDocURL URLByAppendingPathComponent:fullFileName];
    
    return finalTargetURL;
}

+ (void) getImageFromServer:(NSString *)URLString WithImageName:(NSString *)imageName completion:(DoneHandler) done{
    ServerManager * serverMgr = [ServerManager shareInstance];
    [serverMgr downloadPictureWithImgFileName:imageName FromURL:URLString completion:done];
}


@end
