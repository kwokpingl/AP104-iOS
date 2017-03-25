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
    KeychainManager * _keychainMgr;
}
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation ConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    _keychainMgr = [KeychainManager sharedInstance];
    _verificationCodeTextField.delegate = self;
    [_verificationCodeTextField setEnabled:true];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    
    UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
    [tap addTarget:self action:@selector(tapped)];
    [self.view addGestureRecognizer:tap];
    
    
    _messageLabel.text = [NSString stringWithFormat:@"驗證碼已傳送至\n%@\n 若有誤,請回上頁更改", _userInfo.getPassword];
    [_nextButton setEnabled:false];
    [_returnButton setEnabled:true];
    
    [_verificationCodeTextField setKeyboardType:UIKeyboardTypeAlphabet];
    
    [self validationWithAction:VERIFICATION_ACTION_SEND Code:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
    
}

#pragma mark - TEXTFIELD
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return true;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.length + range.location > textField.text.length){
        return false;
    }
    NSInteger newLenght = textField.text.length + string.length - range.length;
    return newLenght <= 5;
}

#pragma mark - BUTTONS
- (IBAction)nextButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"InputPhoto" sender:self];
    // this is where KEYCHAIN and USER LOGIN should take place AND DELETE validationCode
    [self validationWithAction:VERIFICATION_ACTION_DELETE Code:@""];
    [self registerCompletion];
    
}

- (IBAction)returnButtonPressed:(id)sender {
    [self validationWithAction:VERIFICATION_ACTION_DELETE Code:@""];
    [self dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - PRIVATE METHOD
- (void) tapped {
    [self.view endEditing:true];
    [self validationWithAction:VERIFICATION_ACTION_CHECK Code:_verificationCodeTextField.text];
}


- (void) validationWithAction: (NSString *) action Code: (NSString *) code{
    [_serverMgr fetchVerificationCodeForPhoneNumber:_userInfo.getPassword Action: action Code: code  completion:^(NSError *error, id result) {
        if ([result[@"result"] boolValue]){
            NSString * message = @"";
            if ([action isEqualToString:VERIFICATION_ACTION_CHECK]){
                message = @"驗證碼正確";
                dispatch_async(dispatch_get_main_queue(), ^{
                    _messageLabel.text = message;
                    [_nextButton setEnabled:true];
                });
            }
        }
        else
        {
            NSString * message = @"";
            if ([action isEqualToString:VERIFICATION_ACTION_CHECK]){
                message = @"驗證碼有誤\n請再次確認";
            }
            else
            {
                message = [NSString stringWithFormat:@"若無收到驗證碼\n請再次確認電話號碼無誤\n%@",_userInfo.getPassword];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _messageLabel.text = [NSString stringWithFormat: message];
            });
        }

    }];
    
}

- (void) registerCompletion{
        [_serverMgr loginAuthorization:@"user" UserName:_userInfo.getUsername UserPhoneNumber:_userInfo.getPassword Action:ACTION_ADD completion:^(NSError *error, id result) {
            if ([result[@"result"] boolValue]){
                // set it in keychain
                [_keychainMgr setKeychainObject:_userInfo.getUsername forKey:_userInfo.getPassword];
                [_nextButton setEnabled:true];
            }else{
                NSString * error = result[@"error"];
                NSLog(@"Error : %@", error);
            }
        }];
}

@end
