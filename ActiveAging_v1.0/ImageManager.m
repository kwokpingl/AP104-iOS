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

#pragma mark - SAVE IMAGEs
+ (void) saveImageWithFileName: (NSString *)imageFileName ImageData:(NSData *) imageData{
    
    NSURL * fullTargetURL = [ImageManager getFullURLWithFileName:imageFileName];
    
#warning SET IMAGE SIZE?
    
    [imageData writeToURL:fullTargetURL atomically:true];
}

#pragma mark - GET IMAGEs
+ (void) getUserImage: (NSInteger) userID completion:(DoneHandler) done{
    NSString * imageName = [NSString stringWithFormat:@"%ld_profile.jpg", userID];
    UIImage * image = [self loadImageWithFileName:imageName];
    if (image == nil){
        [self getImageFromServer:USER_PIC_URL WithImageName:imageName completion:^(NSError *error, id result) {
            if (!error){
                [ImageManager saveImageWithFileName:imageName ImageData:result];
                done(nil, result);
            }
            else {
                NSLog(@"ERROR GETTING USER IMAGE : %@", error);
                done(error, nil);
            }
        }];
    }
    else {
        NSData * result = UIImageJPEGRepresentation(image, 0.7);
        done(nil,result);
    }
}

+ (void) getEventImage: (NSString *) eventImageName completion:(DoneHandler) done {
    
    UIImage * image = [self loadImageWithFileName:eventImageName];
    if (image == nil){
        [self getImageFromServer:EVENT_PIC_URL WithImageName:eventImageName completion:^(NSError *error, id result) {
            if (!error){
                [ImageManager saveImageWithFileName:eventImageName ImageData:result];
                done(nil, result);
            }
            else {
                NSLog(@"ERROR GETTING EVENT IMAGE: %@", error);
                done(error, nil);
            }
        }];
    }
    else {
        NSData * result = UIImageJPEGRepresentation(image, 0.7);
        done(nil,result);
    }
}

#pragma mark - LOAD IMAGES
+ (UIImage *) loadImageWithFileName: (NSString *) fileName{
    NSURL * fullTargetURL = [ImageManager getFullURLWithFileName:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullTargetURL.path]){
        NSData * data = [NSData dataWithContentsOfURL:fullTargetURL];
        return [UIImage imageWithData:data];
    }
    return nil;
}

#pragma mark - PRIVATE METHODS
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
