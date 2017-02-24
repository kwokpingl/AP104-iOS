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

@interface MemberDetailViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet CallButton *callingBtn;
@property (weak, nonatomic) IBOutlet UIButton *trackerBtn;
@property (weak, nonatomic) IBOutlet UIView *trackingView;
@property (weak, nonatomic) IBOutlet UILabel *trackerLabel;



@end

@implementation MemberDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_callingBtn addTarget:self action:@selector(makeACall:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_cancelBtn addTarget:self action:@selector(cancelBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [ImageManager getUserImage:_userID completion:^(NSError *error, id result) {
        if (error){
            NSLog(@"Error: %@", error);
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_imageView setImage:[UIImage imageWithData:result]];
                [_imageView setContentMode:UIViewContentModeScaleAspectFit];
            });
        }
        
    }];
    UIImage * image = [UIImage imageNamed:@"callBtn"];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_callingBtn setBackgroundImage:image forState:UIControlStateNormal];
    [_callingBtn setContentMode:UIViewContentModeScaleAspectFit];
    [_callingBtn setTitle:@"" forState:UIControlStateNormal];
    [_trackerBtn setTitle:@"導航" forState:UIControlStateNormal];
    [_trackerBtn addTarget:self action:@selector(showTracker) forControlEvents:UIControlEventTouchUpInside];
    [_trackerBtn.titleLabel setFont:[UIFont fontWithName:@"System" size:25]];
    [_trackingView setHidden:true];
    [_trackerLabel setNumberOfLines:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) makeACall: (CallButton *) sender{
    [sender callNumber];
}

- (void) cancelBtnPressed:(id) sender {
    if ([_trackingView isHidden]){
        [self willMoveToParentViewController:nil];
        [self.view.superview setHidden:true];
        [self.view removeFromSuperview];
    }
    else{
        [_trackingView setHidden:true];
        [_imageView setHidden:false];
        [_trackerBtn setEnabled:true];
    }
}

- (void) setNextStep:(NSString *)nextStep{
    [_trackerLabel setText:nextStep];
}

- (void) showTracker {
    [_trackingView setHidden:false];
    [_imageView setHidden:true];
    [_trackerBtn setEnabled:false];
}


@end
