//
//  MemberDetailViewController.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/18.
//  Copyright © 2017年 PING. All rights reserved.
//



#import <UIKit/UIKit.h>

@protocol MemberDetailViewControllerDelegate <NSObject>
@required
- (void) cancelBtnPressed:(id) sender;
@end

@interface MemberDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) NSArray * steps;
@property (weak, nonatomic) NSString * nextStep;
@property (assign) NSInteger userID;
//@property (weak, nonatomic) IBOutlet UIButton *trackingBtn;
@property (weak, nonatomic) id <MemberDetailViewControllerDelegate> delegate;

- (void) setNextStep:(NSString *)nextStep;

@end
