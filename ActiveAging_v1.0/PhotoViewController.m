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
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PhotoViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    ServerManager * serverMgr;
    UserInfo * userInfo;
}
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _photoImageView.image = [UIImage imageNamed:@"Plus.png"];
    
    serverMgr = [ServerManager shareInstance];
    userInfo = [UserInfo shareInstance];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)finishButtonPressed:(id)sender {
    // UPLOAD PHOTO
    // compress photo
    NSData * imgData = UIImageJPEGRepresentation(_photoImageView.image, 0.7);
    
    // SEND
    [serverMgr uploadPictureWithData:imgData Authorization:@"user" UserName:userInfo.getUsername UserPhoneNumber:userInfo.getPassword completion:^(NSError *error, id result) {
        if ([result[@"result"] boolValue]){
            NSLog(@"SUCCESS: %@", result[@"message"]);
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
    
    [alert addAction:camera];
    [alert addAction:photoLibrary];
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
