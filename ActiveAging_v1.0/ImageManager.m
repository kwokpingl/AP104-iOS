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


+ (void) getEventImage: (NSString *) eventImageName completion:(DoneHandler) done {
    
    [self getImageFromServer:EVENT_PIC_URL WithImageName:eventImageName completion:done];
    
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
