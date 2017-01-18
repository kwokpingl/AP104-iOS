//
//  ConfirmationViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "ServerManager.h"
#import "UserInfo.h"
#import "KeychainManager.h"

@interface ConfirmationViewController () <UITextFieldDelegate>{
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    KeychainManager * _keyMgr;
}
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation ConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    _keyMgr = [KeychainManager sharedInstance];
    _verificationCodeTextField.delegate = self;
    [_verificationCodeTextField setEnabled:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
//    
//    NSString * message = _serverMgr.message;
//
    
    [_nextButton setEnabled:true];
    
    [textField resignFirstResponder];
    return true;
}

- (IBAction)nextButtonPressed:(id)sender {
    [_serverMgr loginAuthorization:@"user" UserName:[_userInfo getUsername] UserPhoneNumber:[_userInfo getPassword] Action:@"create"];
    
    if ([_keyMgr setKeychainObject:[_userInfo getUsername] forKey:[_userInfo getPassword]]){
        [_nextButton setEnabled:true];
        [self performSegueWithIdentifier:@"inputPicture" sender:self];
    } else {
        NSString * message = @"error at keyChain";
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"對話框"
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert animated:true completion:nil];
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
