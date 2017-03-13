//
//  OrganizationViewController.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/12.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "OrganizationViewController.h"
#import "CallButton.h"
#import "Definitions.h"

@interface OrganizationViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *organizationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizationLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizerLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizerTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellphoneLabel;
@property (weak, nonatomic) IBOutlet CallButton *cellPhoneBtn;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet CallButton *phoneBtn;
@property (weak, nonatomic) IBOutlet UILabel *faxLabel;
@property (weak, nonatomic) IBOutlet UILabel *faxNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailBtn;
@property (weak, nonatomic) IBOutlet UILabel *webSiteTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *webSiteLabel;


@end

@implementation OrganizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    NSLog(@"%@", _eventDictionary);
    [self analyzeEventDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
    
}

- (void) analyzeEventDetail{
    if (_image != nil){
        _imageView.image = _image;
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    [_webSiteTitleLabel setAdjustsFontSizeToFitWidth:true];
    [_organizationLabel setAdjustsFontSizeToFitWidth:true];
    [_organizerLabel setAdjustsFontSizeToFitWidth:true];
    [_faxNumberLabel setAdjustsFontSizeToFitWidth:true];
    [_cellphoneLabel setAdjustsFontSizeToFitWidth:true];
    [_phoneLabel setAdjustsFontSizeToFitWidth:true];
    [_emailLabel setAdjustsFontSizeToFitWidth:true];

    [_cellPhoneBtn.titleLabel setAdjustsFontSizeToFitWidth:true];
    [_phoneBtn.titleLabel setAdjustsFontSizeToFitWidth:true];
    [_emailBtn.titleLabel setAdjustsFontSizeToFitWidth:true];
    [_cellPhoneBtn.titleLabel setNumberOfLines:0];
    [_phoneBtn.titleLabel setNumberOfLines:0];
    [_emailBtn.titleLabel setNumberOfLines:0];
    
    [_organizationTitleLabel setText:_eventDictionary[EVENT_ORGNTION_KEY]];
    [_organizerTitleLabel setText:_eventDictionary[EVENT_ORGN_NAME_KEY]];
    [_organizationTitleLabel setTextAlignment:NSTextAlignmentLeft];
    [_organizationTitleLabel setNumberOfLines:0];
    [_organizerTitleLabel setNumberOfLines:0];
    [_organizerTitleLabel setTextAlignment:NSTextAlignmentLeft];
    
    NSString * key = EVENT_ORGN_CELL_KEY;
    [_cellPhoneBtn setHidden:true];
    if (_eventDictionary[key]!= [NSNull null]){
        NSString * numberStr = [NSString stringWithFormat:@"0%ld",[_eventDictionary[key] integerValue]];
        [_cellPhoneBtn setTitle:numberStr forState:UIControlStateNormal];
        [_cellPhoneBtn setPhoneNumber:numberStr];
        [_cellPhoneBtn addTarget:self action:@selector(makeACall:) forControlEvents:UIControlEventTouchUpInside];
        [_cellPhoneBtn setEnabled:true];
        [_cellPhoneBtn setHidden:false];
    }
    
    key = EVENT_ORGN_PHONE_KEY;
    [_phoneBtn setHidden:true];
    if (_eventDictionary[key]!= [NSNull null]){
        NSString * numberStr = [NSString stringWithFormat:@"%@",_eventDictionary[key]];
        [_phoneBtn setTitle:numberStr forState:UIControlStateNormal];
        [_phoneBtn setPhoneNumber:_eventDictionary[key]];
        [_phoneBtn addTarget:self action:@selector(makeACall:) forControlEvents:UIControlEventTouchUpInside];
        [_phoneBtn setEnabled:true];
        [_phoneBtn setHidden:false];
    }
    
    key = EVENT_ORGN_FAX_KEY;
    [_faxNumberLabel setHidden:true];
    if (_eventDictionary[key]!= [NSNull null]){
        [_faxNumberLabel setText:_eventDictionary[key]];
        [_faxNumberLabel setHidden:false];
    }
    
    key = EVENT_ORGN_EMAIL_KEY;
    [_emailBtn setHidden:true];
    if (_eventDictionary[key]!= [NSNull null]){
        [_emailBtn setTitle:_eventDictionary[key] forState:UIControlStateNormal];
        [_emailBtn setEnabled:true];
        [_emailBtn setHidden:false];
    }
}

- (void) makeACall: (CallButton *) sender{
    [sender callNumber];
}

@end
