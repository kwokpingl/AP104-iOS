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
    [_descriptionLabel setText:_eventDetailDict[EVENT_DESCRIPTION_KEY]];
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, [self getLabelHeight:_descriptionLabel]*2.0)];
    
//    if ([self getLabelHeight:_descriptionLabel] > self.view.frame.size.height){
//    
//        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, [self getLabelHeight:_descriptionLabel])];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)getLabelHeight:(UILabel*)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
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
