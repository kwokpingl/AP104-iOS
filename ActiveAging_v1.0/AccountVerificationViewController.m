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
#import "WelcomeViewController.h"


@interface AccountVerificationViewController (){
    KeychainManager * _keyChainManager;
    UserInfo * _userInfo;
    BOOL foundKeychain;
}
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@end

@implementation AccountVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _keyChainManager = [KeychainManager sharedInstance];
}

- (void)viewDidAppear:(BOOL)animated{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    imageView.image = [UIImage imageNamed:@"Cuties.jpg"];
    [self.view addSubview:imageView];
    foundKeychain = [_keyChainManager foundKeychain];
    

    
    // Check if KEYCHAIN_ITEM is AVALIABLE
    if (foundKeychain){
        [_welcomeLabel setText:[NSString stringWithFormat:@"歡迎回來%@", [_userInfo getUsername]]];
    }else{
        [_welcomeLabel setText:@"歡迎來到「哈啦哈啦趣」"];
    }
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:false block:^(NSTimer * _Nonnull timer) {
        [self segueSwitching:timer];
    }];
    [timer fire];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) segueSwitching:(NSTimer *) timer{
    [timer invalidate];
    if (foundKeychain){
        [self performSegueWithIdentifier:@"Login" sender:self];
    } else {
        [self performSegueWithIdentifier:@"SignUp" sender:self];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
