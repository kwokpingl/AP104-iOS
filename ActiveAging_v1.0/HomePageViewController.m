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

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showClock) userInfo:nil repeats:YES];
    
    //Start
    [[RACObserve([WeatherManager sharedManager], currentCondition)
      
      //2
      //Delivers any changes on the main thread since you’re updating the UI
      deliverOn: RACScheduler.mainThreadScheduler]
     subscribeNext: ^(WeatherCondition * newCondition) {
         
         NSString * temp = [NSString stringWithFormat:@"%.0f°C",newCondition.temperature.floatValue];
         [_weatherBtn setTitle:temp forState:UIControlStateNormal];
         
         UIImage * image = [[UIImage imageNamed:[newCondition imageName]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
         
         [_weatherBtn setImage: image forState:UIControlStateNormal];
         _weatherBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
         _weatherBtn.titleLabel.numberOfLines = 0;
     }];
    
    [[WeatherManager sharedManager] findCurrentLocation];
    
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

-(void) showClock {
    
    NSDate * now = [NSDate date];
    NSDateFormatter * timeFormatter = [NSDateFormatter new];
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    
#pragma mark - set _timeLabel
    timeFormatter.dateStyle = NSDateFormatterNoStyle;
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    
    _timeLabel.text = [timeFormatter stringFromDate:now];
    
#pragma mark - set _dateLabel
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
//    NSLog(@"%@", [dateFormatter stringFromDate:now]);
    
    _dateLabel.text = [dateFormatter stringFromDate:now];
    
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) setup{
    [_timeLabel setFrame:CGRectMake(0, 0, self.view.frame.size.width/2.0, self.view.frame.size.height/5.0)];
    [_timeLabel setBounds:CGRectMake(self.view.frame.size.width/2.0, self.view.frame.size.height/4, _timeLabel.frame.size.width, _timeLabel.frame.size.height)];
}


@end
