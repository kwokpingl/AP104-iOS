//
//  TimeViewController.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/12.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "TimeViewController.h"
#import "DateManager.h"
#import "Definitions.h"

@interface TimeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeTitle;
@property (weak, nonatomic) IBOutlet UILabel *registrationStartTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *registrationStartTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *registrationEndTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *registrationEndTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventStartTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventStartTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventEndTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventEndTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;

@end

@implementation TimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setup {
    [_timeTitle setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    [_registrationStartTitleLabel setAdjustsFontSizeToFitWidth:true];
    [_registrationStartTitleLabel setNumberOfLines:0];
    
    NSString * date = _eventDetailDict[EVENT_REG_BEGIN_KEY];
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:DATE_FORMAT];
    date = [DateManager convertDateOnly:date withFormatter:formatter];
    [_registrationStartTimeLabel setNumberOfLines:0];
    [_registrationStartTimeLabel setText:date];
    
    date = _eventDetailDict[EVENT_REG_END_KEY];
    date = [DateManager convertDateOnly:date withFormatter:formatter];
    [_registrationEndTimeLabel setNumberOfLines:0];
    [_registrationEndTimeLabel setText:date];
    
    [_eventTitleLabel setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    date = _eventDetailDict[EVENT_START_KEY];
    date = [DateManager convertDateTime:date withFormatter:formatter];
    [_eventStartTimeLabel setNumberOfLines:0];
    [_eventStartTimeLabel setText:date];
    
    date = _eventDetailDict[EVENT_END_KEY];
    date = [DateManager convertDateTime:date withFormatter:formatter];
    [_eventEndTimeLabel setNumberOfLines:0];
    [_eventEndTimeLabel setText:date];
}

@end
