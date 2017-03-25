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
#import "ImageManager.h"
#import "EmergencyButton.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface SetupViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    KeychainManager * _keychainMgr;
    UserInfo * _userInfo;
    ServerManager * _serverMgr;
    BOOL shareLocation;
}
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel * userNameTitle;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet EmergencyButton * emergencyButton;
@property UISwitch * shareLocationSwitch;
@property UILabel * shareLocationLabel;

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    // Do any additional setup after loading the view.
    _keychainMgr = [KeychainManager sharedInstance];
    _userInfo = [UserInfo shareInstance];
    _serverMgr = [ServerManager shareInstance];
    
    [self pageSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DELETE ACCOUNT PRESSED
- (IBAction)deleteAccountPressed:(id)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"您確定要刪除帳號?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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

    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
   
}

#pragma mark - EDITBTN PRESSED
- (void) editButtonPressed {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"更改" message:@"請選擇要更改的項目" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * name = [UIAlertAction actionWithTitle:@"名字" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"更改名字" message:@"請填入您的姓名" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:@"姓名"];
        }];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField * textField = alert.textFields.firstObject;
            if (![textField.text isEqualToString:_userInfo.getUsername]){
                NSPredicate * namePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", NAME_REX];
                BOOL namePass = [namePredicate evaluateWithObject:textField.text];
                if (namePass){
                    [_userInfo setUserInfo:textField.text userPassword:_userInfo.getPassword];
                    [_keychainMgr updateKeychain:_userInfo.getUsername forKey:_userInfo.getPassword];
                    [_serverMgr updateUserNameForAuthorization:@"user" completion:^(NSError *error, id result) {
                        if ([result[ECHO_RESULT_KEY] boolValue]){
                            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"完成" message:@"名字已更新" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [self pageSetup];
                            }];
                            [alert addAction:ok];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self presentViewController:alert animated:true completion:nil];
                            });
                            
                        }
                        else
                        {
                            NSString * error = result[ECHO_ERROR_KEY];
                            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"完成" message:error preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil];
                            [alert addAction:ok];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self presentViewController:alert animated:true completion:nil];
                            });
                        }
                    }];

                }
                else
                {
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"錯誤" message:@"請勿輸入符號" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:ok];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:true completion:nil];
                    });
                }
            }
        }];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:true completion:nil];
        });
    }];
    
    /// MARK: PICTURE BUTTON
    UIAlertAction * picture = [UIAlertAction actionWithTitle:@"照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self photoButtonPressed];
    }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:name];
    [alert addAction:picture];
    [alert addAction:cancel];
    
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void) shareLocationPressed {
    shareLocation = !shareLocation;
    [_userInfo changeShareLocation];
    NSString * shareLabelText = @"已關閉分享定位";
    if (shareLocation){
        shareLabelText = @"已開啟分享定位";
    }
    [_shareLocationLabel setText:shareLabelText];
}

#pragma mark - PHOTOBTN PRESSED
- (void) photoButtonPressed {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"挑照片" message:@"請挑選來源" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * camera = [UIAlertAction actionWithTitle:@"照相機" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self launchPickerWithType:UIImagePickerControllerSourceTypeCamera];
    }];
    UIAlertAction * photoLibrary = [UIAlertAction actionWithTitle:@"圖庫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self launchPickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:camera];
    [alert addAction:photoLibrary];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark - IMAGE-PICKER
// MARK: CONTROLLER
- (void) launchPickerWithType: (UIImagePickerControllerSourceType) type {
    if (![UIImagePickerController isSourceTypeAvailable:type]){
        return;
    }
    
    UIImagePickerController * imgPicker = [UIImagePickerController new];
    imgPicker.sourceType = type;
    imgPicker.mediaTypes = @[(NSString *)kUTTypeImage];
    
    // for later use
    if (type == UIImagePickerControllerSourceTypeCamera){
        
    } else {
        imgPicker.allowsEditing = true;
    }
    
    imgPicker.delegate = self;
    
    [self presentViewController:imgPicker animated:true completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage * originalImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage * editedImg = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage * finalImg = editedImg;
    
    if (finalImg == nil){
        finalImg = originalImg;
    }
    [picker dismissViewControllerAnimated:true completion:^{
        _userImageView.image = finalImg;
        NSData * imgData = UIImageJPEGRepresentation(_userImageView.image, 0.7);
        [self uploadImage:imgData];
    }];
}


#pragma mark - PRIVATE METHOD
- (void) uploadImage: (NSData *) imgData{
    [_serverMgr uploadPictureWithData:imgData Authorization:@"user" UserName:_userInfo.getUsername UserPhoneNumber:_userInfo.getPassword completion:^(NSError *error, id result) {
        if ([result[@"result"] boolValue]){
            NSLog(@"SUCCESS: %@", result[@"message"]);
            
            [_userInfo setProfileImage:_userImageView.image];
            
            NSString * imageName = [NSString stringWithFormat:@"%ld_profile.jpg",_userInfo.getUserID];
            
            [ImageManager saveImageWithFileName:imageName
                                      ImageData:UIImageJPEGRepresentation(_userImageView.image, 0.7)];
        } else {
            NSLog(@"FAILED: %@", result[@"error"]);
        }
    }];
}

#pragma mark - PAGE SETUP
- (void) pageSetup {
    
    /// MARK: IMAGE
    CGFloat imageWidth = self.view.frame.size.width*2.0/4.0;
    [_userImageView setFrame:CGRectMake((self.view.frame.size.width - imageWidth)/2.0, self.view.frame.size.height/6.0, imageWidth, imageWidth)];
    [_userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_userImageView.layer setCornerRadius:_userImageView.frame.size.width/3.0];
    [_userImageView.layer setMasksToBounds:true];
    [ImageManager getUserImage:_userInfo.getUserID completion:^(NSError *error, id result) {
        if (!error){
            _userImageView.image = [UIImage imageWithData:result];
        }
        else{
            _userImageView.image  = nil;
        }
    }];
    
    
    /// MARK: LABELS
    _userNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, _userImageView.frame.size.height + _userImageView.frame.origin.y + 10, self.view.frame.size.width/2.0 - 20, _userImageView.frame.size.height/3.0)];
    [_userNameTitle setFont:[UIFont systemFontOfSize:32.0]];
    [_userNameTitle setTextColor:[UIColor blueColor]];
    [_userNameTitle setAdjustsFontSizeToFitWidth:true];
    [_userNameTitle setText: @"姓名"];
    [_userNameTitle setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:_userNameTitle];
    
    [_userNameLabel setFrame:CGRectMake(_userNameTitle.frame.size.width + _userNameTitle.frame.origin.x *3.0, _userNameTitle.frame.origin.y, _userNameTitle.frame.size.width, _userNameTitle.frame.size.height)];
    [_userNameLabel setFont:[UIFont systemFontOfSize:32.0]];
    [_userNameLabel setAdjustsFontSizeToFitWidth:true];
    [_userNameLabel setText: _userInfo.getUsername];
    [_userNameLabel setTextAlignment:NSTextAlignmentLeft];
    
    /// MARK: BUTTONS
    _emergencyButton = [EmergencyButton new];
    [self.view addSubview:_emergencyButton];
    
    CGFloat spaceBtwLabEm = _emergencyButton.frame.origin.y - (_userNameLabel.frame.origin.y + _userNameLabel.frame.size.height);
    
    [_deleteButton setFrame:CGRectMake(10, _emergencyButton.frame.origin.y - spaceBtwLabEm, self.view.frame.size.width/2.0-10, spaceBtwLabEm/2.0)];
    [_deleteButton.titleLabel setFont:[UIFont systemFontOfSize:32]];
    [_deleteButton.titleLabel setAdjustsFontSizeToFitWidth:true];
    [_deleteButton.titleLabel setNumberOfLines:0];
    [_deleteButton setTitle:@"刪除帳號" forState:UIControlStateNormal];
    
    [_editButton setFrame:CGRectMake(self.view.frame.size.width - 10 - _deleteButton.frame.size.width, _deleteButton.frame.origin.y, _deleteButton.frame.size.width, _deleteButton.frame.size.height)];
    [_editButton setTitle:@"更改" forState:UIControlStateNormal];
    [_editButton.titleLabel setFont:[UIFont systemFontOfSize:32]];
    [_editButton.titleLabel setAdjustsFontSizeToFitWidth:true];
    [_editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    shareLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:@"shareLocation"] boolValue];
    
    
    _shareLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_deleteButton.frame.origin.x, _deleteButton.frame.origin.y + _deleteButton.frame.size.height, _deleteButton.frame.size.width, _deleteButton.frame.size.height)];
    
    NSString * shareLabelText = @"已關閉分享定位";
    if (shareLocation){
        shareLabelText = @"已開啟分享定位";
    }
    
    [_shareLocationLabel setText:shareLabelText];
    [_shareLocationLabel setFont:[UIFont systemFontOfSize:32]];
    [_shareLocationLabel setAdjustsFontSizeToFitWidth:true];
    [_shareLocationLabel setNumberOfLines:0];
    [_shareLocationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_shareLocationLabel];
    
    _shareLocationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake((_editButton.frame.origin.x+_editButton.frame.size.width/4.0), _shareLocationLabel.frame.origin.y, _editButton.frame.size.width/2.0, _editButton.frame.size.height)];
    [_shareLocationSwitch addTarget:self action:@selector(shareLocationPressed) forControlEvents:UIControlEventValueChanged];
    [_shareLocationSwitch setOn:shareLocation];
    [self.view addSubview:_shareLocationSwitch];
}

- (void) emergencyBtnPressed{
    
}


@end
