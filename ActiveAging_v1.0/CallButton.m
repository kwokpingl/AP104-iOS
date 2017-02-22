//
//  CallButton.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/14.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "CallButton.h"

@implementation CallButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) setPhoneNumber:(NSString *)phoneNumber{
    _phoneNumber = phoneNumber;
}



- (void) callNumber{
    // iOS 8 tel: does the same as telpromt://
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _phoneNumber]];
    NSLog(@"NSURL url = %@", url);
    [[UIApplication sharedApplication] openURL:url];
}

@end
