//
//  DescriptionViewController.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/12.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "DescriptionViewController.h"
#import "Definitions.h"

@interface DescriptionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *labelView;

@end

@implementation DescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [_descriptionLabel drawTextInRect:UIEdgeInsetsInsetRect(_descriptionLabel.frame, UIEdgeInsetsMake(20, 10, 20, 10))];
    [_labelView.layer setBorderColor:[UIColor blackColor].CGColor];
    [_labelView.layer setBorderWidth:2.0];
    
    [_descriptionTitleLabel setAdjustsFontSizeToFitWidth:true];
    [_descriptionLabel setNumberOfLines:0];
//    [_descriptionLabel.layer setBorderColor:[UIColor blackColor].CGColor];
//    [_descriptionLabel.layer setCornerRadius:_descriptionLabel.frame.size.width/10];
//    [_descriptionLabel.layer setBorderWidth:0.5];
    [_descriptionLabel setText:_eventDetailDict[EVENT_DESCRIPTION_KEY]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
