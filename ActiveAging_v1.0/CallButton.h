//
//  CallButton.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/14.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallButton : UIButton
@property (strong, nonatomic) NSString * phoneNumber;
- (void) setPhoneNumber:(NSString *)phoneNumber;
- (void) callNumber;
@end
