//
//  WelcomeBackViewController.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/24.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "WelcomeBackViewController.h"
#import "HomePageViewController.h"
#import "WeatherManager.h"
#import "AccountVerificationViewController.h"

@interface WelcomeBackViewController () <CLLocationManagerDelegate> {
    CLLocationManager * locationManager;
    UILabel * temperatureLabel;
    UILabel * conditionsLabel;
    UILabel * welcomingLabel;
    UIImageView * iconView;
    NSString * imageName;
}

@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, strong) NSDateFormatter * hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter * dailyFormatter;

@end

@implementation WelcomeBackViewController

-(id) init {
    if (self = [super init]) {
        NSLocale * twLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
        
        _hourlyFormatter = [NSDateFormatter new];
        _hourlyFormatter.dateFormat = @"h a";
        _hourlyFormatter.locale = twLocale;
        
        _dailyFormatter = [NSDateFormatter new];
        _dailyFormatter.dateFormat = @"EEEE";
        _dailyFormatter.locale = twLocale;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 175, self.view.frame.size.width, 150)];
    _button.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_button];
    
#pragma mark - set up Image View
    //1
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
#pragma mark - set up frames and margins
    //Set up layout frames and margins
    //1
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    //2
    CGFloat inset = 20;
    //3
    CGFloat temperatureHeight = 110;
    CGFloat iconHeight = 80;
    
    //4
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + 40),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    
    //5
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 30);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 30);
    
#pragma mark - set up labels
    
    welcomingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 500, self.view.frame.size.width, 500.0)];
    
    //2 - bottom left
    temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor blackColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:120];
    [self.view addSubview:temperatureLabel];

    conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:45];
    conditionsLabel.textColor = [UIColor blackColor];
    [self.view addSubview: conditionsLabel];
    
    //3 - bottom left
    iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:iconView];
    
#pragma mark - Observe the current Condition
    //1
    //Observes the currentCondition key on the WeatherManager singleton
    [[RACObserve([WeatherManager sharedManager], currentCondition)
      
      //2
      //Delivers any changes on the main thread since you’re updating the UI
      deliverOn: RACScheduler.mainThreadScheduler]
     subscribeNext: ^(WeatherCondition * newCondition) {
         
         // 3
         //Updates the text labels with weather data; you’re using newCondition for the text and not the singleton. The subscriber parameter is guaranteed to be the new value
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°C",newCondition.temperature.floatValue];
         conditionsLabel.text = [newCondition.condition capitalizedString];
         
         // 4
         //Uses the mapped image file name to create an image and sets it as the icon for the view
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
         
         imageName = [newCondition imageName];
         
         self.backgroundImageView.image = [self setBackgroundImage];
         self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
         [self.view insertSubview:_backgroundImageView atIndex:0];
         
         //5 Welcome Button
         [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
      
         [_button setTitle:[self welcomingTitle] forState:UIControlStateNormal];
         _button.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
         
         _button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
         [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
         _button.titleLabel.font = [UIFont systemFontOfSize:25];
     }];
    [[WeatherManager sharedManager] findCurrentLocation];
}

- (UIImage * ) setBackgroundImage {
    UIImage * bkg = [UIImage new];
    
    if ([imageName isEqualToString:@"tstorm"]) {
        bkg = [UIImage imageNamed:@"tstormBg"];
    }
    
    else if ([imageName isEqualToString:@"moon"]) {
        bkg = [UIImage imageNamed:@"nightClear"];
    }
    
    else if ([imageName isEqualToString:@"rain"] || [imageName isEqualToString:@"shower"]) {
        bkg = [UIImage imageNamed:@"rainBg"];
    }
    
    else if ([imageName isEqualToString:@"sunny"]) {
        bkg = [UIImage imageNamed:@"sunnyBg"];
    }
    
    else if ([imageName isEqualToString:@"broken"] || [imageName isEqualToString:@"few"]) {
        bkg = [UIImage imageNamed:@"sunset"];
    }
    
    else if ([imageName isEqualToString:@"brokenNight"] || [imageName isEqualToString:@"few-night"]) {
        bkg = [UIImage imageNamed:@"brokenN"];
    }
    
    else {
        bkg = [UIImage imageNamed:@"LaunchScreen"];
    }
    
    return bkg;
}

- (NSString * ) welcomingTitle {
    NSString * title;
    
    if ([imageName isEqualToString:@"tstorm"] || [imageName isEqualToString:@"shower"] || [imageName isEqualToString:@"rain"]) {
        title = @"出門小心，要記得帶雨傘喔。";
    }
    
    else if ([imageName isEqualToString:@"moon"]) {
        title = @"天高氣爽，祝您有個美好的夜晚。";
    }
    
    else if ([imageName isEqualToString:@"sunny"]) {
        title = @"晴空萬里，外出記得要防曬喔。";
    }
    
    else if ([imageName isEqualToString:@"broken"] || [imageName isEqualToString:@"few"] || [imageName isEqualToString:@"brokenNight"] || [imageName isEqualToString:@"few-night"]) {
        title = @"今天有點雲，要留意天氣變化喔。";
    }
    
    else if ([imageName isEqualToString:@"typhoon"]) {
        title = @"颱風天，待在室內也能玩得愉快。";
    }
    
    else {
        title = @"";
    }
    
    return title;
}

- (void) viewWillAppear:(BOOL)animated {
    
    //Setting navigation controller background
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = true;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) buttonPressed: (UIButton *) sender{
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstVC"];
    [self.navigationController pushViewController:vc animated:true];
    
}

@end
