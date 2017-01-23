//
//  InputNameViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "InputNameViewController.h"
#import "UserInfo.h"
#import "ServerManager.h"
#import "KeychainManager.h"

@interface InputNameViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>{
    UserInfo * _userInfo;
    ServerManager * _serverMgr;
    KeychainManager * _keyMgr;
    int counter;
    
}
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;


@end

@implementation InputNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // SETUP SINGLETON
    [_nextButton setEnabled:false];
    _userInfo   = [UserInfo shareInstance];
    _serverMgr  = [ServerManager shareInstance];
    _keyMgr     = [KeychainManager sharedInstance];
    
    // SETUP TEXTFIELD
    _lastnameTextField.delegate     = self;
    _firstnameTextField.delegate    = self;
    _phoneNumberTextField.delegate  = self;
        // KEYBOARD_TYPE
    _firstnameTextField.keyboardType = UIKeyboardTypeAlphabet;
    _firstnameTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    _lastnameTextField.keyboardType = UIKeyboardTypeAlphabet;
    _lastnameTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    
    // SETUP GESTURE
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(tapped)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // SETUP COUNTER
    counter = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TEXTFIELD_BUTTON_GESTURE
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self validation:ACTION_CHECK];
    [textField resignFirstResponder];
    return true;
}

- (IBAction)nextButtonPressed:(id)sender {
    [self validation:ACTION_ADD];
    [self performSegueWithIdentifier:@"confirmation" sender:self];
}

- (void) tapped {
    [self.view endEditing:true];
    [self validation:ACTION_CHECK];
}

#pragma mark - PRIVATE_METHODS
- (void) validation : (NSString *) action {
    if (![_lastnameTextField.text isEqualToString:@""] &&
        ![_firstnameTextField.text isEqualToString:@""] &&
        (_phoneNumberTextField.text.length == 10)){
        
        NSString * username = [_lastnameTextField.text stringByAppendingString:_firstnameTextField.text];
        
        NSString * userPhoneNumber = _phoneNumberTextField.text;
        
        [_userInfo setUserInfo:username userPassword:userPhoneNumber];
        
        [_serverMgr loginAuthorization:@"user" UserName:_userInfo.getUsername UserPhoneNumber:_userInfo.getPassword Action:action completion:^(NSError *error, id result) {
            if ([result[@"result"] boolValue]){
                // set it in keychain
//                [_keyMgr setValue:username forKey:userPhoneNumber];
                    [_nextButton setEnabled:true];
            }else{
                NSString * error = result[@"error"];
                NSLog(@"Error : %@", error);
            }
        }];
        
    } else {
        [_nextButton setEnabled:false];
    }

}

@end
