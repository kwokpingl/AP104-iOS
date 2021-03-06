//
//  EmergencyButton.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/5.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "EmergencyButton.h"
#import "DataManager.h"
#import "Definitions.h"
#import "EmergencyViewController.h"
//#import <CoreTelephony/CTTelephonyNetworkInfo.h>
//#import <CoreTelephony/CTCarrier.h>
//#import <CallKit/CallKit.h>
///<>
@interface EmergencyButton() {
    NSInteger counter;
    NSTimer * timer;
}
@property NSMutableArray * emergencyNumbers;
//@property CXCallObserver * observer;
@property BOOL callsStop;
@end

@implementation EmergencyButton

- (void) callNumbers: (UINavigationController *) controller{
    EmergencyViewController * vc = [EmergencyViewController new];
    [controller presentViewController:vc animated:true completion:nil];
}

-(void)didMoveToSuperview {
    self.imageView.image = [UIImage imageNamed:@"Emer"];
    [self setTitle:@"緊急連絡" forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:40]];
    self.tintColor = [UIColor whiteColor];
    [self setBackgroundImage:[UIImage imageNamed:@"Emer"] forState:UIControlStateNormal];
    [self setFrame:CGRectMake(self.superview.frame.size.width/4.0,
                              self.superview.frame.size.height * 9.0/10.0,
                              self.superview.frame.size.width/2.0,
                              self.superview.frame.size.height/10.0)];
    [self setEnabled:true];
}

//- (void) stopCalls {
//    _callsStop = true;
//}

//- (void) getEmergencyNumbers {
//    NSArray * details = [DataManager fetchDatabaseFromTable:EMERGENCY_TABLE];
//    
//    
//    if (details.count > 0){
//        _emergencyNumbers = [NSMutableArray new];
//        for (NSDictionary * dic in details){
//            [_emergencyNumbers addObject:dic[USER_PHONENUMBER_KEY]];
//        }
//    }
//    
//    CTTelephonyNetworkInfo * networkInfo = [[CTTelephonyNetworkInfo alloc] init];
//    NSString * code = [networkInfo.subscriberCellularProvider mobileCountryCode];
//    
//    _emergencyNumbers = [@[@"0918756081", @"0918756081", @"0918756081"] mutableCopy];
//    if (!_callsStop){
//        [self makeCalls:counter];
//    }
//    
//}

//- (void) makeCalls: (NSInteger) callIndex {
//    
//    
//    if (callIndex < _emergencyNumbers.count){
//        NSString * phoneNumber = _emergencyNumbers[callIndex];
//        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]];
//        NSLog(@"PHONE NUMBER : %@", phoneNumber);
//        [[UIApplication sharedApplication] openURL:url];
//    }
//}
//
//-(void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
//    NSString * callerID = [call.UUID UUIDString];
//    
//    NSLog(@"CALLER ID : %@", callerID);
//    [timer invalidate];
//    timer = nil;
//    
//    if(!call.hasConnected && !call.hasEnded && !call.onHold)
//    {
//        if(call.outgoing)
//        {
//            // outgoing call is being dialling;
//        }
//    }
//    else if(call.onHold)
//    {
//        // call is on hold;
//    }
//    else if(call.hasEnded)
//    {
//        // call has disconnected;
//        counter++;
//        NSLog(@"COUNTER : %ld", counter);
//        if (counter < _emergencyNumbers.count){
//            timer = [NSTimer timerWithTimeInterval:2.0 repeats:false block:^(NSTimer * _Nonnull timer) {
//                [self makeCalls:counter];
//            }];
//            [timer fire];
//        }
//    }
//    else if(call.hasConnected)
//    {
//        // call has been answered;
//    }
//    
//}


@end
