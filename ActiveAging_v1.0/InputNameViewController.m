//
//  InputNameViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "InputNameViewController.h"
#import "UserInfo.h"

@interface InputNameViewController () <UITextFieldDelegate>{
    UserInfo * userInfo;
}
@property (weak, nonatomic) IBOutlet UITextField *lastnameTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstnameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *completeUIImageView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;


@end

@implementation InputNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem.backBarButtonItem setAction:@selector(backBarButtonItem)];
    _lastnameTextField.delegate = self;
    _firstnameTextField.delegate = self;
    [_nextButton setBackgroundColor:[UIColor redColor]];
    userInfo = [UserInfo shareInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) backButtonPressed: (id) sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (![_lastnameTextField.text isEqualToString:@""] && ![_firstnameTextField.text isEqualToString:@""]){
        [_nextButton setBackgroundColor:[UIColor greenColor]];
    } else {
        [_nextButton setBackgroundColor:[UIColor redColor]];
    }
    [textField resignFirstResponder];
    return true;
}

- (IBAction)nextButtonPressed:(id)sender {
    if ([_firstnameTextField.text isEqualToString:@""] || [_lastnameTextField.text isEqualToString:@""]){
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"還沒填完哦" message:@"請完全填完後再按喔！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        return;
    }
    
    NSString * fullName = [_firstnameTextField.text stringByAppendingString:[NSString stringWithFormat:@" %@",_lastnameTextField.text]];
    [userInfo setUserInfo:fullName userPassword:nil];
    [self performSegueWithIdentifier:@"inputPhoneNumber" sender:self];
    
}

- (IBAction)undoButtonPressed:(id)sender {
    [_lastnameTextField setText:@""];
    [_firstnameTextField setText:@""];
    [_nextButton setBackgroundColor:[UIColor redColor]];
}




@end
