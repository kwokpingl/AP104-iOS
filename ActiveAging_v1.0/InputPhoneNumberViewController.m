//
//  InputPhoneNumberViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "InputPhoneNumberViewController.h"
#import "UserInfo.h"
#import "ServerManager.h"

@interface InputPhoneNumberViewController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>{
    UserInfo * _userInfo;
    ServerManager * _serverMger;
}
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIPickerView *areaPicker;
@property (strong, nonatomic) NSArray * countries;
@end

@implementation InputPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _userInfo = [UserInfo shareInstance];
    _serverMger = [ServerManager shareInstance];
    
    _phoneNumberTextField.delegate = self;
    
    [_nextButton setBackgroundColor:[UIColor redColor]];
    _countries = @[@{@"country":@"台灣",@"areaCode": @"011886"}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayMessage) name:@"showResult" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([_phoneNumberTextField.text isEqualToString:@""]){
        [_nextButton setBackgroundColor:[UIColor redColor]];
    }else {
        
        [_serverMger loginAuthorization:@"user" UserName:[_userInfo getUsername] UserPhoneNumber:_phoneNumberTextField.text Action:@"checkout"];
        [_nextButton setEnabled:NO];
        
        [_nextButton setBackgroundColor:[UIColor greenColor]];
    }
    
    
    
    [textField resignFirstResponder];
    return true;
}

- (IBAction)nextButtonPressed:(id)sender {
    if ([_phoneNumberTextField.text isEqualToString:@""]){
        return;
    }
    
    [self performSegueWithIdentifier:@"confirmation" sender:self];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return _countries.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString * fullText = [_countries[row][@"country"] stringByAppendingString:_countries[row][@"areacode"]];
    return fullText;
}

- (void) displayMessage {
    NSString * message = _serverMger.message;
    if ([message isEqualToString:@"Valid Account"]){
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"對話框" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        
        [_userInfo setUserInfo:[_userInfo getUsername] userPassword:_phoneNumberTextField.text];
    }
    [_nextButton setEnabled:true];
}


@end
