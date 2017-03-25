//
//  CallButton.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/14.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "CallButton.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation CallButton


- (void) setPhoneNumber:(NSString *)phoneNumber{
    _phoneNumber = phoneNumber;
}



- (void) callNumber{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    NSString *code = [networkInfo.subscriberCellularProvider mobileCountryCode];
    
    //this is nil if you take out sim card.
    if (code == nil) {
        
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"錯誤訊息" message:@"沒發現 Sim 卡" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        
        [alertView addAction:cancel];
        
        NSLog(@"NO SIM: %@", _phoneNumber);
        
        return;
    }
    
    // iOS 8 tel: does the same as telpromt://
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _phoneNumber]];
    NSLog(@"NSURL url = %@", url);
    [[UIApplication sharedApplication] openURL:url];
}



@end
