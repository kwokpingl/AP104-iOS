//
//  PhotoViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "PhotoViewController.h"
#import "WelcomeViewController.h"
#import "ServerManager.h"
#import "UserInfo.h"
#import "KeychainManager.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PhotoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    KeychainManager * _keychainMgr;
}
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _photoImageView.image = [UIImage imageNamed:@"Plus.png"];
    
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    _keychainMgr = [KeychainManager sharedInstance];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)finishButtonPressed:(id)sender {
    // disable the button
    [_finishedButton setEnabled: false];
    // UPLOAD PHOTO
    // compress photo
    NSData * imgData = UIImageJPEGRepresentation(_photoImageView.image, 0.7);
    
    // SEND
    [_serverMgr uploadPictureWithData:imgData Authorization:@"user" UserName:_userInfo.getUsername UserPhoneNumber:_userInfo.getPassword completion:^(NSError *error, id result) {
        if ([result[@"result"] boolValue]){
            NSLog(@"SUCCESS: %@", result[@"message"]);
            
            [_userInfo setProfileImage:_photoImageView.image];
            
            [_keychainMgr setKeychainObject:_userInfo.getUsername forKey:_userInfo.getPassword];
            
            UIViewController * vc = [self.storyboard
                                     instantiateViewControllerWithIdentifier:@"AccountVerificationViewController"];
            [self presentViewController:vc animated:true completion:nil];
            
        } else {
            NSLog(@"FAILED: %@", result[@"error"]);
        }
    }];
    
}

- (IBAction)addPhotoButtonPressed:(id)sender {
    // pop out alert
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
        _photoImageView.image = finalImg;
    }];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:true completion:nil];
}

@end
