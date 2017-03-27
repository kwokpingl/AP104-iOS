//
//  MemberDetailViewController.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/18.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "MemberDetailViewController.h"
#import "CallButton.h"
#import "ImageManager.h"
#import "LocationManager.h"
#import "MapViewController.h"

@interface MemberDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet CallButton *callingBtn;
@property (weak, nonatomic) IBOutlet UIButton *trackerBtn;
@property (weak, nonatomic) IBOutlet UIView *trackingView;
@property (weak, nonatomic) IBOutlet UILabel *trackerLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation MemberDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_imageView.layer setCornerRadius:_imageView.frame.size.height/2.5];
    [_imageView.layer setMasksToBounds:true];
    if (_userID != 0){
        [ImageManager getUserImage:_userID completion:^(NSError *error, id result) {
            if (error){
                NSLog(@"Error: %@", error);
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_imageView setImage:[UIImage imageWithData:result]];
                });
            }
            
        }];
    } else if (_userID == -1){
        [_imageView setImage:_customImage];
    } else {
        [ImageManager getEventImage:_eventImageName completion:^(NSError *error, id result) {
            if (error){
                NSLog(@"Error: %@", error);
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_imageView setImage:[UIImage imageWithData:result]];
                });
            }
        }];
    }
    UIImage * image = [UIImage imageNamed:@"callBtn"];
    [_callingBtn addTarget:self action:@selector(makeACall:) forControlEvents:UIControlEventTouchUpInside];
    [_callingBtn setTitle:@"" forState:UIControlStateNormal];
    [_callingBtn setBackgroundImage:image forState:UIControlStateNormal];
    [_callingBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_callingBtn setPhoneNumber:_phoneNumber];
    
    [_cancelBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:25]];
    [_cancelBtn.titleLabel setAdjustsFontSizeToFitWidth:true];
    
    [_trackerBtn setTitle:@"導航" forState:UIControlStateNormal];
    [_trackerBtn addTarget:self action:@selector(showTracker) forControlEvents:UIControlEventTouchUpInside];
    [_trackerBtn.titleLabel setFont:[UIFont systemFontOfSize:25]];
    [_trackerBtn.titleLabel setAdjustsFontSizeToFitWidth:true];
    
    
    [_trackingView setHidden:true];
    
    [_trackerLabel setNumberOfLines:0];
    
    [_titleLabel setText:_name];
    [_titleLabel setNumberOfLines:0];
    [_titleLabel setFont:[UIFont systemFontOfSize:25]];
    [_titleLabel setAdjustsFontSizeToFitWidth:true];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [[LocationManager shareInstance] stopUpdatingHeading];
    if([self.parentViewController isKindOfClass:[MapViewController class]]){
        [((MapViewController *)self.parentViewController).mapview setUserTrackingMode:MKUserTrackingModeNone];
    }
}

- (void) makeACall: (CallButton *) sender{
    [sender callNumber];
}

- (void) cancelBtnPressed:(id) sender {
    if ([_trackingView isHidden]){
        [self willMoveToParentViewController:nil];
        [self removeFromParentViewController];
        [self didMoveToParentViewController:nil];
        [self.view.superview setHidden:true];
        [self.view removeFromSuperview];
    }
    else{
        [_trackingView setHidden:true];
        [_imageView setHidden:false];
        [_trackerBtn setEnabled:true];
    }
    [[LocationManager shareInstance] stopUpdatingHeading];
    
    if([self.parentViewController isKindOfClass:[MapViewController class]]){
        [((MapViewController *)self.parentViewController).mapview setUserTrackingMode:MKUserTrackingModeNone];
    }
}

- (void) setNextStep:(NSString *)nextStep{
    [_trackerLabel setText:nextStep];
}

- (void) showTracker {
    [_trackingView setBackgroundColor:[UIColor clearColor]];
    [_trackingView setHidden:false];
    [_imageView setHidden:true];
    [_trackerBtn setEnabled:false];
    
    [[LocationManager shareInstance] startUpdatingHeading];
    
    NSLog(@"PARENT VIEW CONTROLLER CALSS : %@", self.parentViewController.class);
    
    if([self.parentViewController isKindOfClass:[MapViewController class]]){
        [((MapViewController *)self.parentViewController).mapview setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    }
    
}

@end
