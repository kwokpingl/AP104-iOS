//
//  HomePageViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "HomePageViewController.h"
#import "WeatherManager.h"
#import "EmergencyButton.h"
#import "LocationManager.h"
#import "EmergencyViewController.h"
#import "DataManager.h"

#define BUTTON_SIDE (self.view.frame.size.height/7.0)

@interface HomePageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIButton *weatherBtn;
@property (weak, nonatomic) IBOutlet UIButton *activityBtn;
@property (weak, nonatomic) IBOutlet UIButton *calendarBtn;
@property (weak, nonatomic) IBOutlet UIButton *contactBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UIButton *mapBtn;
@property (weak, nonatomic) IBOutlet EmergencyButton *emergencyBtn;
@property (strong, nonatomic) LocationManager * locationMgr;

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self pageSetup];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showClock) userInfo:nil repeats:YES];
//    [_emergencyBtn addTarget:self action:@selector(callEmergency)
//            forControlEvents:UIControlEventTouchUpInside];
    
    [DataManager updateEventDatabase];
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.toolbar.hidden = true;
    [[WeatherManager sharedManager] findCurrentLocation];
    
    //Start
    [[RACObserve([WeatherManager sharedManager], currentCondition)
      
      //2
      //Delivers any changes on the main thread since you’re updating the UI
      deliverOn: RACScheduler.mainThreadScheduler]
     subscribeNext: ^(WeatherCondition * newCondition) {
         if (newCondition != nil){
         dispatch_async(dispatch_get_main_queue(), ^{
             NSString * temp = [NSString stringWithFormat:@"%.0f°C",newCondition.temperature.floatValue];
             [_weatherBtn setTitle:temp forState:UIControlStateNormal];
             
             UIImage * image = [[UIImage imageNamed:[newCondition imageName]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
             
             [_weatherBtn setImage: image forState:UIControlStateNormal];
             _weatherBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
             _weatherBtn.titleLabel.numberOfLines = 0;
         });
         }
         
     }];
    
    _locationMgr = [LocationManager shareInstance];
    if ([_locationMgr accessGranted]){
        [_locationMgr startMonitoringSignificatnLocationChanges];
    }

    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    NSLog(@"TestViewController Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef) self));
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) callEmergency {
    [_emergencyBtn callNumbers:self.navigationController];
}

-(void) showClock {
    NSDate * now = [NSDate date];
    NSDateFormatter * timeFormatter = [NSDateFormatter new];
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    
#pragma mark - set _timeLabel
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    timeFormatter.dateStyle = NSDateFormatterNoStyle;
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    
    _timeLabel.text = [timeFormatter stringFromDate:now];
    
#pragma mark - set _dateLabel
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    _dateLabel.text = [dateFormatter stringFromDate:now];
}


- (void) pageSetup{
    [self.navigationItem setTitle:@"哈啦哈啦趣"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:25]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    
    
    CGFloat timeLabelHeight = self.view.frame.size.height/10.0;
    
    [_timeLabel setFrame:CGRectMake(self.view.frame.size.width*1.0/3.0,
                                    self.view.frame.size.height *2.0/3.0 - timeLabelHeight,
                                    self.view.frame.size.width *2.0/3.0,
                                    timeLabelHeight)];
    [_dateLabel setFrame:CGRectMake(_timeLabel.frame.origin.x,
                                    _timeLabel.frame.origin.y-10.0,
                                    _timeLabel.frame.size.width * 2.5/3.0,
                                    _timeLabel.frame.size.height/3.0)];
    [_emergencyBtn setFrame:CGRectMake(self.view.frame.size.width/4.0,
                                       self.view.frame.size.height * 9.0/10.0,
                                       self.view.frame.size.width/2.0,
                                       self.view.frame.size.height/10.0)];
    [_settingsBtn setFrame:CGRectMake(self.view.frame.size.width-10.0-BUTTON_SIDE,
                                      _timeLabel.frame.origin.y + _timeLabel.frame.size.height + 20 ,
                                      BUTTON_SIDE,
                                      BUTTON_SIDE)];
    [_contactBtn setFrame:CGRectMake(self.view.frame.size.width/3.0,
                                     _timeLabel.frame.origin.y + _timeLabel.frame.size.height + 5.0,
                                     BUTTON_SIDE*4/3,
                                     BUTTON_SIDE*4/3)];
    [_mapBtn setFrame:CGRectMake(10,
                                 _dateLabel.frame.origin.y,
                                 BUTTON_SIDE,
                                 BUTTON_SIDE)];
    [_calendarBtn setFrame:CGRectMake(_mapBtn.frame.origin.x + 5.0,
                                      _mapBtn.frame.origin.y * 2.0/3.0,
                                      BUTTON_SIDE,
                                      BUTTON_SIDE)];
    [_activityBtn setFrame:CGRectMake(_calendarBtn.frame.size.width * 3.0/4.0 + _calendarBtn.frame.origin.x,
                                      _calendarBtn.frame.origin.y * 2.0/3.0,
                                      BUTTON_SIDE,
                                      BUTTON_SIDE)];
    [_weatherBtn setFrame:CGRectMake(self.view.frame.size.width/2.0,
                                     _activityBtn.frame.origin.y/2.0,
                                     BUTTON_SIDE*4/3,
                                     BUTTON_SIDE*4/3)];
    
    [_timeLabel setFont:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:50]];
    [_timeLabel setAdjustsFontSizeToFitWidth:false];
    [_timeLabel setNumberOfLines:1];
    
    [_dateLabel setFont:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:25]];
    [_dateLabel setAdjustsFontSizeToFitWidth:false];
    [_dateLabel setNumberOfLines:1];
    
//    [_emergencyBtn.titleLabel setFont:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:40]];
//    [_emergencyBtn setBackgroundImage:[UIImage imageNamed:@"Emer"] forState:UIControlStateNormal];
//    [_emergencyBtn setTintColor:[UIColor whiteColor]];
//    [_emergencyBtn setTitle:@"緊急連絡" forState:UIControlStateNormal];
    [_emergencyBtn addTarget:self action:@selector(callEmergency) forControlEvents:UIControlEventTouchUpInside];
    
    [_settingsBtn.titleLabel setFont:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:40]];
    [_settingsBtn setTitle:@"設定" forState:UIControlStateNormal];
    [_settingsBtn.titleLabel setAdjustsFontSizeToFitWidth:false];
    
    [_contactBtn.titleLabel setFont:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:40]];
    [_contactBtn.titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [_contactBtn setTitle:@"聯絡人" forState:UIControlStateNormal];
    [_contactBtn.titleLabel setAdjustsFontSizeToFitWidth:false];
    
    [_mapBtn.titleLabel setFont:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:40]];
    [_mapBtn setTitle:@"地圖" forState:UIControlStateNormal];
    [_mapBtn.titleLabel setAdjustsFontSizeToFitWidth:false];
    
    [_calendarBtn.titleLabel setFont:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:40]];
    [_calendarBtn.titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [_calendarBtn setTitle:@"日曆" forState:UIControlStateNormal];
    [_calendarBtn.titleLabel setAdjustsFontSizeToFitWidth:false];
    
    [_activityBtn.titleLabel setFont:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:40]];
    [_activityBtn setTitle:@"活動" forState:UIControlStateNormal];
    [_activityBtn.titleLabel setAdjustsFontSizeToFitWidth:false];
    
    [_weatherBtn.titleLabel setFont:[UIFont fontWithName:@"Tensentype-XiaoXiaoXinF" size:40]];
}


@end
