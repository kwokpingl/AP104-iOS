//
//  EmergencyViewController.m
//  ActiveAging_v1.0
//
//  Created by Jimmy on 2017/3/8.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "EmergencyViewController.h"
#import "DataManager.h"
#import "Definitions.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CallKit/CallKit.h>

@interface EmergencyViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSInteger counter;
    NSInteger timeCounter;
    NSTimer * countDownTimer;
}
@property NSMutableArray * emergencyNumbers;
@property CXCallObserver * observer;
@property CTCallCenter * callCenter;
@property UIView * countDownView;
@property UILabel * countDownLabel;
@property UIButton * countDownBtn;
@property BOOL callsStop;
@end

@implementation EmergencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _callsStop = false;
    
    
    
    
    
    
    
    CTTelephonyNetworkInfo * networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString * code = [networkInfo.subscriberCellularProvider mobileCountryCode];
    
    _callCenter = [CTCallCenter new];
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self getEmergencyNumbers];
    [self pageSetup];
    
    counter = 0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [self callEmergency];
}

- (void) callEmergency {
    if (counter == _emergencyNumbers.count){
        [self dismissViewControllerAnimated:true completion:nil];
    }
    if (!_callsStop) {
        [self makeCalls:counter];
    }
}


#pragma mark - ===TableView===
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _emergencyNumbers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
    }
    
    [cell.textLabel setText:_emergencyNumbers[indexPath.row]];
    return cell;
}

#pragma mark - ===Private Methods===

- (void) makeCalls: (NSInteger) callIndex {
    counter ++;
    if (callIndex < _emergencyNumbers.count && !_callsStop){
        NSString * phoneNumber = _emergencyNumbers[callIndex];
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]];
        NSLog(@"PHONE NUMBER : %@", phoneNumber);
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void) callStop {
    _callsStop = true;
}


-(void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    NSString * callerID = [call.UUID UUIDString];
    
    NSLog(@"CALLER ID : %@", callerID);
    
    if(!call.hasConnected && !call.hasEnded && !call.onHold)
    {
        if(call.outgoing)
        {
            // outgoing call is being dialling;
        }
    }
    else if(call.onHold)
    {
        // call is on hold;
    }
    else if(call.hasEnded)
    {
//        // call has disconnected;
//        counter++;
//        NSLog(@"COUNTER : %ld", counter);
//        if (counter < _emergencyNumbers.count){
//            [self makeCalls:counter];
//        }
    }
    else if(call.hasConnected)
    {
        // call has been answered;
    }
    
}

- (void) countDown:(NSTimer *) timer {
    timeCounter --;
    if (timeCounter <= 0){
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
}

#pragma mark - ===SETUP===
- (void) pageSetup {
    
    CGRect tableViewFrame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height * 0.8);
    UITableView * tableView = [[UITableView alloc] initWithFrame:tableViewFrame
                                                           style:UITableViewStylePlain];
    CGFloat buttonWidth = tableView.frame.size.width * 0.5;
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0 - buttonWidth/2.0, tableView.frame.size.height + 10.0, buttonWidth, (self.view.frame.size.height - tableView.frame.size.height - 10.0)/2.0 )];
    [button setTitle:@"結束" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(callStop) forControlEvents:UIControlEventTouchUpInside];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [self.view addSubview:tableView];
    
    timeCounter = 5;
    _countDownView = [[UIView alloc] initWithFrame:self.view.frame];
    [_countDownView setBackgroundColor:[UIColor redColor]];
    
}

- (void) getEmergencyNumbers {
    NSArray * details = [DataManager fetchDatabaseFromTable:EMERGENCY_TABLE];
    
    
    if (details.count > 0){
        _emergencyNumbers = [NSMutableArray new];
        for (NSDictionary * dic in details){
            [_emergencyNumbers addObject:dic[USER_PHONENUMBER_KEY]];
        }
    }
    
}

@end
