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


@interface AccountVerificationViewController (){
    KeychainManager * _keychainMgr;
    UserInfo * _userInfo;
    ServerManager * _serverMgr;
    
    BOOL foundKeychain;
    NSTimer * timer;
}
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet UIButton * resetButton;
@end

@implementation AccountVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _keychainMgr = [KeychainManager sharedInstance];
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];

}

- (void)viewDidAppear:(BOOL)animated{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    imageView.image = [UIImage imageNamed:@"LaunchScreen"];
    imageView.layer.zPosition = 0;
    [self.view addSubview:imageView];
    
    _welcomeLabel.layer.zPosition=1;
    
    _resetButton = [[UIButton alloc] initWithFrame:_welcomeLabel.frame];
    [_resetButton addTarget:self action:@selector(resetButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_resetButton setHidden:true];
    [self.view addSubview: _resetButton];
    
    timer = [NSTimer timerWithTimeInterval:2.0 repeats:false block:^(NSTimer * _Nonnull timer) {
        [self segueSwitching];
    }];
    [self checkKeyChain];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
                    [_welcomeLabel setText:[NSString stringWithFormat:@"歡迎回來%@", [_userInfo getUsername]]];
                });
                NSArray * allKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
                
                if (![allKeys containsObject:@"shareLocation"]){
                    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"shareLocation"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                NSLog(@"SHARE_LOCATION? :%d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"shareLocation"] boolValue]);
                
                NSString * userID = result[@"message"];
                [_userInfo setUserID:[userID integerValue]];
                [timer fire];
            } else {

                dispatch_async(dispatch_get_main_queue(), ^{
                    [_welcomeLabel setText:@"發生錯誤\n請確定網路開啟\n再點選這裡登入"];
                    [_resetButton setHidden:false];
//                    [_keychainMgr deleteKeychain:_userInfo.getUsername Password:_userInfo.getPassword];
                });
            }
        }];
        
        
        // fetch profile image
        
        
    }else{
        [_welcomeLabel setText:@"歡迎來到「哈啦哈啦趣」"];
        [timer fire];
    }
}

- (void) resetButtonPressed{
//    [_keychainMgr deleteKeychain:_userInfo.getUsername Password:_userInfo.getPassword];
    [self checkKeyChain];
}

@end
