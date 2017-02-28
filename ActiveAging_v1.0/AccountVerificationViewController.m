//
//  AccountVerificationViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/11/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "AccountVerificationViewController.h"
#import "KeychainManager.h"
#import "UserInfo.h"
#import "ServerManager.h"
#import "WelcomeViewController.h"
#import "DataManager.h"
#import "Definitions.h"
#import "WeatherManager.h"
#import "LocationManager.h"

@interface AccountVerificationViewController () <CLLocationManagerDelegate> {
    KeychainManager * _keychainMgr;
    UserInfo * _userInfo;
    ServerManager * _serverMgr;
    LocationManager * _locationMgr;
    
    BOOL foundKeychain;
    NSTimer * timer;
    
    // WEATHER
    CLLocationManager * locationManager;
    UILabel * temperatureLabel;
    UILabel * conditionsLabel;
    UIImageView * iconView;
    NSString * imageName;
    
    NSDate * date;
    NSDateFormatter * dateFormat;
    NSString * currentDate;
}
@property (strong, nonatomic) UIView * welcomeView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet UIButton * resetButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CGFloat screenHeight;
@end

@implementation AccountVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _keychainMgr = [KeychainManager sharedInstance];
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    
    date = [NSDate date];
    dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:@"HH"];
    currentDate = [dateFormat stringFromDate:date];
}

- (void)viewDidAppear:(BOOL)animated{
    // ADD IMAGE VIEW
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_imageView setImage:[UIImage imageNamed:@"LaunchScreen"]];
    [_imageView.layer setZPosition:0];
    [self.view addSubview:_imageView];
    
    [_welcomeLabel.layer setZPosition:1.0];
    [_welcomeLabel setFrame:CGRectMake(0, self.view.frame.size.height/2.0, self.view.frame.size.width, self.view.frame.size.height/5.0)];
    
    _resetButton = [[UIButton alloc] initWithFrame:_welcomeLabel.frame];
    [_resetButton addTarget:self action:@selector(resetButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_resetButton setHidden:true];
    [self.view addSubview: _resetButton];
    
    timer = [NSTimer timerWithTimeInterval:2.0 repeats:false block:^(NSTimer * _Nonnull timer) {
        [self segueSwitching];
    }];
    [self checkKeyChain];
}

- (void) viewWillAppear:(BOOL)animated {
    //Setting navigation controller background
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:true];
    [self.navigationController.view setBackgroundColor:[UIColor clearColor]];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - WEATHER FORCAST
- (void) setupHeartTouchingNotice {
    
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    
    _welcomeView = [[UIView alloc] initWithFrame:mainFrame];
    [_welcomeView insertSubview:_imageView atIndex:0];
    
    UIButton * enterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _welcomeLabel.frame.origin.y/2.0, self.view.frame.size.width, _welcomeLabel.frame.origin.y/2.0)];
    [enterButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [enterButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
    [enterButton setTitleColor:[UIColor blueColor]
                      forState:UIControlStateNormal];
    [enterButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [enterButton.titleLabel setFont:[UIFont systemFontOfSize:25]];
    
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(enterButton.frame.size.width*3.0/4.0, enterButton.frame.size.height*2.0/3.0, enterButton.frame.size.width/4.0, enterButton.frame.size.height/3.0)];
    [label setBounds:enterButton.frame];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blueColor]];
    
    [enterButton addSubview:label];
    [_welcomeView addSubview:enterButton];
    
#pragma mark - set up frames and margins
    //Set up layout frames and margins

    //2
    CGFloat inset = 20;
    //3
    CGFloat temperatureHeight = 110;
    CGFloat iconHeight = 80;
    
    //4
    CGRect temperatureFrame = CGRectMake(inset,
                                         mainFrame.size.height - (temperatureHeight + 40),
                                         mainFrame.size.width - (2 * inset),
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
    //2 - bottom left
    temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor blackColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:120];
    [_welcomeView addSubview:temperatureLabel];
    
    conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:45];
    conditionsLabel.textColor = [UIColor blackColor];
    conditionsLabel.numberOfLines = 0;
    conditionsLabel.adjustsFontSizeToFitWidth = true;
    [_welcomeView addSubview: conditionsLabel];
    
    //3 - bottom left
    iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [_welcomeView addSubview:iconView];
    
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
         if ([[newCondition imageName] isEqualToString:@"few"]) {
             if ([currentDate floatValue] >= 18.0 || [currentDate floatValue] <= 6.0) {
                 iconView.image = [UIImage imageNamed:@"few-night"];
                 
             } else {
                 iconView.image = [UIImage imageNamed:@"few-day"];
             }
         }
         else {
             iconView.image = [UIImage imageNamed:[newCondition imageName]];
         }
         
         imageName = [newCondition imageName];
         
         [_imageView setImage:[self setBackgroundImage]];
         [_imageView setContentMode:UIViewContentModeScaleAspectFill];
         
         //5 Welcome Button
         
         
         [enterButton setTitle:[self welcomingTitle] forState:UIControlStateNormal];
         
         
         
         label.text = @"請點擊進入喔！";
         label.font = [UIFont systemFontOfSize:20];
     }];
    
    [[WeatherManager sharedManager] findCurrentLocation];
    [self.view addSubview:_welcomeView];
}

/// MARK: WEATHER_IMAGE
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
        
        if ([currentDate floatValue] >= 18.0 || [currentDate floatValue] <= 6.0) {
            bkg = [UIImage imageNamed:@"brokenN"];
        } else {
            bkg = [UIImage imageNamed:@"sunset"];
        }
    }
    else {
        bkg = [UIImage imageNamed:@"LaunchScreen"];
    }
    return bkg;
}

/// MARK: WEATHER_TITLE
- (NSString * ) welcomingTitle {
    NSString * title;
    
    if ([imageName isEqualToString:@"tstorm"] || [imageName isEqualToString:@"shower"] || [imageName isEqualToString:@"rain"]) {
        title = @"今天有雨，出門記得帶雨傘喔。";
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
        title = @"祝您有個美好的一天。";
    }
    
    return title;
}

#pragma mark - BUTTONS
- (void) buttonPressed: (UIButton *) sender{
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstVC"];
    [self presentViewController:vc animated:true completion:nil];
}

- (void) resetButtonPressed{
    //    [_keychainMgr deleteKeychain:_userInfo.getUsername Password:_userInfo.getPassword];
    [self checkKeyChain];
}

#pragma mark - PRIVATE METHOS
- (void) segueSwitching{
    [timer invalidate];
    if (foundKeychain){
        [DataManager prepareDatabase];
        [DataManager updateContactDatabase];
        [self performSegueWithIdentifier:@"Login" sender:self];
    } else {
        [self performSegueWithIdentifier:@"SignUp" sender:self];
    }
}

- (void) checkKeyChain{
    foundKeychain = [_keychainMgr foundKeychain:^(NSString *userName, NSString *userPhoneNumber) {
        [_userInfo setUserInfo:userName userPassword:userPhoneNumber];
    }];
    
    
    // Check if KEYCHAIN_ITEM is AVALIABLE
    if (foundKeychain){
        // check if user is correct
        [_serverMgr loginAuthorization:@"user" UserName:_userInfo.getUsername UserPhoneNumber:_userInfo.getPassword Action:ACTION_GET_ID completion:^(NSError *error, id result) {
            if ([result[@"result"] boolValue]){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_welcomeLabel setText:[NSString stringWithFormat:@"歡迎回來，%@", [_userInfo getUsername]]];
                });
                
                NSArray * allKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
                
                if (![allKeys containsObject:@"shareLocation"]){
                    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"shareLocation"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                NSLog(@"SHARE_LOCATION? :%d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"shareLocation"] boolValue]);
                
                NSString * userID = result[@"message"];
                [_userInfo setUserID:[userID integerValue]];
                //                [timer fire];
                [self setupHeartTouchingNotice];
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_welcomeLabel setText:@"發生錯誤\n請確定網路開啟\n再點選這裡登入"];
                    [_resetButton setHidden:false];
                    //                    [_keychainMgr deleteKeychain:_userInfo.getUsername Password:_userInfo.getPassword];
                });
            }
        }];
        
    }else{
        [_welcomeLabel setText:@"歡迎來到「哈啦哈啦趣」"];
        [timer fire];
    }
}


@end
