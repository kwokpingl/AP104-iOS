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
#import "EventManager.h"
#import "Reachability.h"

@interface AccountVerificationViewController () <CLLocationManagerDelegate> {
    KeychainManager * _keychainMgr;
    UserInfo * _userInfo;
    ServerManager * _serverMgr;
    WeatherManager * _weatherMgr;
    Reachability * reachability;
    
    UITapGestureRecognizer * gestureKeyNotFound;
    UITapGestureRecognizer * gestureKeyFound;
    BOOL foundKeychain;
    NSTimer * timer;
    
    // WEATHER
    UILabel * temperatureLabel;
    UILabel * conditionsLabel;
    NSString * imageName;
    UIImageView * iconView;
    
    NSDateFormatter * dateFormat;
    NSString * currentDate;
    NSDate * date;
    
    NSInteger counter;
}
@property (strong, nonatomic) UIView * welcomeView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CGFloat screenHeight;
@property UIButton * enterButton;
@end

@implementation AccountVerificationViewController

#pragma mark - ===VIEW===
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
    
    [_welcomeLabel setText:@""];
    [_welcomeLabel setNumberOfLines:0];
    [_welcomeLabel setTextColor:[UIColor blackColor]];
    
    gestureKeyNotFound = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(resetButtonPressed)];
    [gestureKeyNotFound setEnabled:false];
    [self.view addGestureRecognizer:gestureKeyNotFound];
    gestureKeyFound = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(segueSwitching)];
    [gestureKeyFound setEnabled:false];
    [self.view addGestureRecognizer:gestureKeyFound];
    [self requestAccessToEventType];
}

- (void)viewDidAppear:(BOOL)animated{
    // ADD IMAGE VIEW
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               self.view.frame.size.width,
                                                               self.view.frame.size.height)];
    [_imageView setImage:[UIImage imageNamed:@"LaunchScreen"]];
    [_imageView.layer setZPosition:0];
    [self.view addSubview:_imageView];
    
    [_welcomeLabel.layer setZPosition:1.0];
    [_welcomeLabel setFrame:CGRectMake(0, self.view.frame.size.height/3.0, self.view.frame.size.width, self.view.frame.size.height/5.0)];
    timer = [NSTimer timerWithTimeInterval:2.0 repeats:false block:^(NSTimer * _Nonnull timer) {
        [self segueSwitching];
    }];
    
    _weatherMgr = [WeatherManager sharedManager];
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

- (void)viewDidDisappear:(BOOL)animated {
    [reachability stopNotifier];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - ===REACHABILITY===
//- (void) reachabilityChanged{
//    if (reachability.currentReachabilityStatus == NotReachable){
//        [_welcomeLabel setText:@"發生錯誤\n請確定網路開啟\n再點選這裡登入"];
//        [_welcomeLabel setBackgroundColor:[UIColor whiteColor]];
//        [gestureKeyNotFound setEnabled:true];
//        [_enterButton setEnabled:false];
//    }
//    else{
//        [self checkKeyChain];
//    }
//    NSLog(@"%ld", counter++);
//}

#pragma mark - ===WEATHER FORCAST===
- (void) setupHeartTouchingNotice {
    
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    
    _welcomeView = [[UIView alloc] initWithFrame:mainFrame];
    [_welcomeView insertSubview:_imageView atIndex:0];
    
    _enterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _welcomeLabel.frame.origin.y/2.0, self.view.frame.size.width, _welcomeLabel.frame.origin.y/2.0)];
    [_enterButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_enterButton setEnabled:false];
    [_enterButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
    [_enterButton setTitleColor:[UIColor blueColor]
                      forState:UIControlStateNormal];
    [_enterButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_enterButton.titleLabel setFont:[UIFont systemFontOfSize:25]];
    
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(_enterButton.frame.size.width*3.0/4.0, _enterButton.frame.size.height*2.0/3.0, _enterButton.frame.size.width/4.0, _enterButton.frame.size.height/3.0)];
    [label setBounds:_enterButton.frame];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blueColor]];
    
    [_enterButton addSubview:label];
    [_welcomeView addSubview:_enterButton];
    
/// MARK: set up frames and margins
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
    
/// MARK: set up labels
    //2 - bottom left
    temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor blackColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:120];
    temperatureLabel.adjustsFontSizeToFitWidth = true;
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
    
/// MARK: Observe the current Condition
    //1
    //Observes the currentCondition key on the WeatherManager singleton
    
    [[RACObserve(_weatherMgr, currentCondition)
      
      //2
      //Delivers any changes on the main thread since you’re updating the UI
      deliverOn: RACScheduler.mainThreadScheduler]
     subscribeNext: ^(WeatherCondition * newCondition) {
         
         
         if (newCondition != nil){
             dispatch_async(dispatch_get_main_queue(), ^{
                 // 3
                 //Updates the text labels with weather data; you’re using newCondition for the text and not the singleton. The subscriber parameter is guaranteed to be the new value
                 temperatureLabel.text = [NSString stringWithFormat:@"%.0f°C",newCondition.temperature.floatValue];
                 conditionsLabel.text = [newCondition.condition capitalizedString];
                 
                 // 4
                 //Uses the mapped image file name to create an image and sets it as the icon for the view
                 if ([[newCondition imageName] containsString:@"few"]) {
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
                 [_enterButton setTitle:[self welcomingTitle] forState:UIControlStateNormal];
                 
                 label.text = @"請點擊進入喔！";
                 label.font = [UIFont systemFontOfSize:20];
             });
         }
     }];
    
    [self.view addSubview:_welcomeView];
}

#pragma mark - ===WEATHER STATUS SETUP===
/// MARK: BACKGROUND
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
    
    else if ([imageName isEqualToString:@"sunny"] || [imageName containsString:@"clear"]) {
        
        if([currentDate floatValue] >= 18.0 || [currentDate floatValue] <= 6.0){
            bkg = [UIImage imageNamed:@"nightClear"];
        }
        else{
            bkg = [UIImage imageNamed:@"sunnyBg"];
        }
    }
    
    else if ([imageName isEqualToString:@"broken"] || [imageName containsString:@"few"]) {
        
        if ([currentDate floatValue] >= 18.0 || [currentDate floatValue] <= 6.0) {
            bkg = [UIImage imageNamed:@"brokenN"];
        } else {
            bkg = [UIImage imageNamed:@"sunset"];
        }
    }
    else if ([imageName isEqualToString:@"mist"]){
        bkg = [UIImage imageNamed:@"Fog"];
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
    
    else if ([imageName isEqualToString:@"broken"] || [imageName containsString:@"few"] || [imageName isEqualToString:@"brokenNight"] || [imageName isEqualToString:@"few-night"]) {
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

#pragma mark - ===BUTTONS===
- (void) buttonPressed: (UIButton *) sender{
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstVC"];
    [self presentViewController:vc animated:true completion:nil];
}

- (void) resetButtonPressed{
    //    [_keychainMgr deleteKeychain:_userInfo.getUsername Password:_userInfo.getPassword];
//    if (reachability.currentReachabilityStatus == NotReachable){
//        [self reachabilityChanged];
//    }
//    else{
//        [self checkKeyChain];
//    }
    [self checkKeyChain];
}

#pragma mark - ===PRIVATE METHODS===
- (void) segueSwitching{
    [timer invalidate];
    if (foundKeychain){
        [self widgetConfiguration:^(NSError *error, id result) {
            [DataManager prepareDatabase];
            [DataManager updateContactDatabase:^(BOOL done) {
                if (done){
                    [self performSegueWithIdentifier:@"Login" sender:self];
                }
            }];
        }];
    } else {
        [self performSegueWithIdentifier:@"SignUp" sender:self];
    }
}

/// MARK: CHECK_KEYCHAIN
- (void) checkKeyChain{
    foundKeychain = [_keychainMgr foundKeychain:^(NSString *userName, NSString *userPhoneNumber) {
        [_userInfo setUserInfo:userName userPassword:userPhoneNumber];
    }];
    
    [gestureKeyFound setEnabled:false];
    [gestureKeyNotFound setEnabled:false];
    
    
    // Check if KEYCHAIN_ITEM is AVALIABLE
    if (foundKeychain){
        [_weatherMgr findCurrentLocation];
        [self setupHeartTouchingNotice];
        
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

                
                //UPDATE TOKEN
                [_serverMgr updateToken:[_userInfo getDeviceToken] completion:^(NSError *error, id result) {
                    if ([result[ECHO_RESULT_KEY] boolValue]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [gestureKeyFound setEnabled:true];
                            [_enterButton setEnabled:true];
                        });
                        
                    }
                }];
                
                
            } else if (error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_welcomeLabel setText:@"發生錯誤\n請確定網路開啟\n再點選這裡登入"];
                    [_welcomeLabel setBackgroundColor:[UIColor whiteColor]];
                    [gestureKeyNotFound setEnabled:true];
                    [_enterButton setEnabled:false];
                });
            }
            
        }];
        
    }else{
        [_welcomeLabel setText:@"歡迎來到「哈啦哈啦趣」"];
        [timer fire];
    }
}


#pragma mark - widgetConfiguration
-(void) widgetConfiguration: (DoneHandler) done {
    NSUserDefaults * sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:WIDGET_NAME];
    
    [sharedDefaults setObject:temperatureLabel.text forKey:@"currentTempTxt"];
    
    [sharedDefaults setObject:conditionsLabel.text forKey:@"currentConditions"];
    
    
    [[EventManager shareInstance] sortTimeOrder:[NSDate date] complete:^(NSMutableArray *eventArray) {
        NSMutableArray * eventsForWidget = [[NSMutableArray alloc] initWithArray:eventArray];
        
        EKEvent * event;
        NSString * dateStr;
        NSString * eventTitle;
        
        NSMutableArray * widgetEvent = [NSMutableArray new];
        
        if (eventsForWidget.count != 0) {
            
            for (int i = 0; i < eventsForWidget.count; i++) {
                event = [eventsForWidget objectAtIndex:i];
                
                NSDateFormatter * today = [NSDateFormatter new];
                today.dateFormat = @"HH:mm";
                
                dateStr = [today stringFromDate:event.startDate];
                eventTitle = event.title;
                
                NSMutableDictionary * dict = [NSMutableDictionary new];
                dict = [@{@"today date":dateStr, @"event title":eventTitle} mutableCopy];
                
                [widgetEvent addObject:dict];
                //the first object contains the latest date and title...
            }
        }
        
        [sharedDefaults setObject:widgetEvent forKey:@"eventsArray"];
        [sharedDefaults synchronize];
        done(nil, @(true));
    }];
}

-(void) requestAccessToEventType {
    [[EventManager shareInstance] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        
        if (error)
        {
            NSLog(@"%@", error);
            return;
        }
        
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"無法存取" message:@"「哈啦哈啦趣」無法存取您的行事曆喔，請允許我們使用您的日曆。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * ok = [UIAlertAction actionWithTitle:@"瞭解" style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction * redirect = [UIAlertAction actionWithTitle:@"設定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [alert addAction:ok];
                [alert addAction:redirect];
                
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        else{
            [EventManager shareInstance].eventsAccessGranted = granted;
        }
        
        
    }];
}

@end
