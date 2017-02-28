//
//  MemberDetailViewController.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/18.
//  Copyright © 2017年 PING. All rights reserved.
//



#import <UIKit/UIKit.h>


@interface MemberDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) NSArray * steps;
@property (weak, nonatomic) NSString * nextStep;
@property (weak, nonatomic) NSString * phoneNumber;
@property (weak, nonatomic) NSString * eventImageName;
@property (weak, nonatomic) NSString * targetTitle;
@property (weak, nonatomic) NSString * name;
@property (weak, nonatomic) UIImage * customImage;
@property (assign) NSInteger userID;


- (void) setNextStep:(NSString *)nextStep;
@end
