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
//#import "KeychainManager.h"

@interface InputNameViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>{
    UserInfo * _userInfo;
    ServerManager * _serverMgr;
//    KeychainManager * _keyMgr;
    int counter;
    
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIImageView *hintImageView;

@end

@implementation InputNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // SETUP SINGLETON
    [_nextButton setEnabled:false];
    _userInfo   = [UserInfo shareInstance];
    _serverMgr  = [ServerManager shareInstance];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    
    // SETUP TEXTFIELD
    _lastnameTextField.delegate     = self;
    _firstnameTextField.delegate    = self;
    _phoneNumberTextField.delegate  = self;
    
    // KEYBOARD_TYPE
    _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    _firstnameTextField.keyboardType = UIKeyboardTypeDefault;    
    _lastnameTextField.keyboardType = UIKeyboardTypeDefault;
    
    
    // SETUP GESTURE
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(tapped)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // SETUP COUNTER
    counter = 0;
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TEXTFIELD_DELEGATE
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self validation:ACTION_CHECK];
    [textField resignFirstResponder];
    return true;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == _phoneNumberTextField){
        NSString * newString = [textField.text
                                stringByReplacingCharactersInRange:range
                                withString:string];
        return !([newString length]>PHONE_NUMBER_LENGTH);
    }
    
    return true;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    [textField setText:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [textField setText: [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    BOOL match;
    
    if (textField == _phoneNumberTextField){
        NSPredicate * phoneNumberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",PHONE_NUMBER_REX];
        
        match = [phoneNumberPredicate evaluateWithObject:textField.text];
        
        if (!match){
            _hintLabel.text = @"請輸入正確手機號碼喔\n09開頭的\n共十位數字";
            
        }
        else{
            _hintLabel.text = @"";
        }
    }
    
    if (textField == _lastnameTextField || textField == _firstnameTextField){
        NSPredicate * namePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", NAME_REX];
        match = [namePredicate evaluateWithObject:textField.text];
        
        if (!match){
            [_hintLabel setText:@"請勿輸入特殊符號"];
        }
        else{
            [_hintLabel setText:@""];
        }
    }
    return true;
}

#pragma mark - BUTTON
- (IBAction)nextButtonPressed:(id)sender {
    
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
        (_phoneNumberTextField.text.length == 10) ){
        
        NSPredicate * namePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", NAME_REX];
        NSPredicate * phoneNumberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",PHONE_NUMBER_REX];
        BOOL lastNameMatch = [namePredicate evaluateWithObject:_lastnameTextField.text];
        BOOL firstNameMatch = [namePredicate evaluateWithObject:_firstnameTextField.text];
        BOOL phoneNumberMatch = [phoneNumberPredicate evaluateWithObject:_phoneNumberTextField.text];
        
        if (lastNameMatch && firstNameMatch && phoneNumberMatch){
            [_hintLabel setText:@""];
            NSString * username = [_lastnameTextField.text stringByAppendingString: [NSString stringWithFormat:@" %@", _firstnameTextField.text]];
            
            NSString * userPhoneNumber = _phoneNumberTextField.text;
            [_userInfo setUserInfo:username userPassword:userPhoneNumber];
            
            [_serverMgr loginAuthorization:@"user" UserName:_userInfo.getUsername UserPhoneNumber:_userInfo.getPassword Action:action completion:^(NSError *error, id result) {
                if ([result[@"result"] boolValue]){
                    [_nextButton setEnabled:true];
                }else{
                    NSString * error = result[@"error"];
                    NSLog(@"Error : %@", error);
                    [_hintLabel setText:error];
                }
            }];
        }
        else{
            if (lastNameMatch || firstNameMatch){
                [_hintLabel setText:@"請輸入正確手機號碼喔\n09開頭的\n共十位數字"];
            }
            else{
                [_hintLabel setText:@"請勿輸入特殊符號"];
            }
            
            [_nextButton setEnabled:false];
        }

    } else {
        
        [_nextButton setEnabled:false];
    }

}

#pragma mark - SETUP PAGE
- (void) setup{
    /// MARK: TITLE
    [_titleLabel setFrame:CGRectMake(0
                                     , 44
                                     , self.view.frame.size.width
                                     , self.view.frame.size.height/20.0)];
    [_titleLabel setText:@"個人設定"];
    [_titleLabel setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[UIFont systemFontOfSize:25.0]];
    [_titleLabel setAdjustsFontSizeToFitWidth:true];
    
    /// MARK: TEXTFIELDs
    [_lastnameTextField setFrame:CGRectMake(10, _titleLabel.frame.origin.y + _titleLabel.frame.size.height+5.0, _titleLabel.frame.size.width-20, _titleLabel.frame.size.height*2)];
    [_lastnameTextField setPlaceholder:@"請輸入您的姓"];
    [_lastnameTextField setTextAlignment:NSTextAlignmentLeft];
    [_lastnameTextField setFont:[UIFont systemFontOfSize:25.0]];
    [_lastnameTextField setAdjustsFontSizeToFitWidth:true];
    [_lastnameTextField setBorderStyle:UITextBorderStyleLine];
    
    [_firstnameTextField setFrame:CGRectMake(_lastnameTextField.frame.origin.x
                                             , _lastnameTextField.frame.origin.y + _lastnameTextField.frame.size.height+5.0
                                             , _lastnameTextField.frame.size.width
                                             , _lastnameTextField.frame.size.height)];
    [_firstnameTextField setPlaceholder:@"請輸入您的名"];
    [_firstnameTextField setFont:[UIFont systemFontOfSize:25.0]];
    [_firstnameTextField setTextAlignment:NSTextAlignmentLeft];
    [_firstnameTextField setAdjustsFontSizeToFitWidth:true];
    [_firstnameTextField setBorderStyle:UITextBorderStyleLine];
    
    [_phoneNumberTextField setFrame:CGRectMake(_firstnameTextField.frame.origin.x
                                               , _firstnameTextField.frame.size.height + _firstnameTextField.frame.origin.y +5.0
                                               , _firstnameTextField.frame.size.width
                                               , _firstnameTextField.frame.size.height)];
    [_phoneNumberTextField setPlaceholder:@"09xxxxxxxx"];
    [_phoneNumberTextField setTextAlignment:NSTextAlignmentLeft];
    [_phoneNumberTextField setFont:[UIFont systemFontOfSize:25]];
    [_phoneNumberTextField setAdjustsFontSizeToFitWidth:true];
    [_phoneNumberTextField setBorderStyle:UITextBorderStyleLine];
    
    /// MARK: NEXT BUTTON
    [_nextButton setFrame:CGRectMake(self.view.frame.size.width * 2.0/3.0, self.view.frame.size.height - 60 - 50, self.view.frame.size.width/3.0, 50)];
    
    
    /// MARK: HINTS
    [_hintImageView setFrame:CGRectMake(_phoneNumberTextField.frame.origin.x
                                        , _phoneNumberTextField.frame.origin.y
                                         + _phoneNumberTextField.frame.size.height + 20
                                        , _phoneNumberTextField.frame.size.width
                                        , _nextButton.frame.origin.y -
                                        (_phoneNumberTextField.frame.origin.y
                                         + _phoneNumberTextField.frame.size.height + 20) -20)];
    [_hintLabel setFrame:_hintImageView.frame];
    [_hintLabel setTextAlignment:NSTextAlignmentCenter];
    [_hintLabel setNumberOfLines:0];
    [_hintLabel setFont:[UIFont systemFontOfSize:25.0]];
    [_hintLabel setText:@"請輸入資料"];
    [_hintLabel setAdjustsFontSizeToFitWidth:true];
    
}

@end
