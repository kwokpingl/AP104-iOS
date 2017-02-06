//
//  SetupViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "SetupViewController.h"
#import "UserInfo.h"
#import "ServerManager.h"
#import "KeychainManager.h"
#import "AccountVerificationViewController.h"

@interface SetupViewController (){
    KeychainManager * _keychainMgr;
    UserInfo * _userInfo;
    ServerManager * _serverMgr;
}

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _keychainMgr = [KeychainManager sharedInstance];
    _userInfo = [UserInfo shareInstance];
    _serverMgr = [ServerManager shareInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteAccountPressed:(id)sender {
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:nil];
    [_keychainMgr deleteKeychain:_userInfo.getUsername Password:_userInfo.getPassword];
    [_serverMgr loginAuthorization:@"user" UserName:_userInfo.getUsername UserPhoneNumber:_userInfo.getPassword Action:ACTION_DELETE completion:^(NSError *error, id result) {
        
        if ([result[@"result"] boolValue]){
            NSLog(@"SUCCESS: %@", result[@"message"]);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountVerificationViewController"];
                [self presentViewController:vc animated:true completion:nil];
            });
        }
        else{
            NSLog(@"Error: %@", error);
        }
        
    }];
    
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
