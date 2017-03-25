//
//  EventTableViewCell.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/22/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [_eventTitleLabel setBackgroundColor:[UIColor whiteColor]];
    [_eventTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_eventTitleLabel setFont:[UIFont systemFontOfSize:25]];
    [_eventTitleLabel setAdjustsFontSizeToFitWidth:true];
    [_eventTitleLabel setNumberOfLines:0];
    
    [_eventLocationLabel setBackgroundColor:[UIColor whiteColor]];
    [_eventLocationLabel setFont:[UIFont systemFontOfSize:25]];
    [_eventLocationLabel setTextAlignment:NSTextAlignmentCenter];
    [_eventLocationLabel setAdjustsFontSizeToFitWidth:true];
    [_eventLocationLabel.layer setCornerRadius:3.0];
    [_eventLocationLabel setNumberOfLines:0];
    
    [_eventOrganizationLabel setBackgroundColor:[UIColor whiteColor]];
    [_eventOrganizationLabel setFont:[UIFont systemFontOfSize:20]];
    [_eventOrganizationLabel setTextAlignment:NSTextAlignmentLeft];
    [_eventOrganizationLabel setAdjustsFontSizeToFitWidth:true];
    
    
    [_eventRegistrationDateLabel setBackgroundColor:[UIColor whiteColor]];
    [_eventRegistrationDateLabel setFont:[UIFont systemFontOfSize:25]];
    [_eventRegistrationDateLabel setTextAlignment:NSTextAlignmentCenter];
    [_eventRegistrationDateLabel setTextColor:[UIColor blueColor]];
    
//    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
//    UIVisualEffectView * visualBlur = [[UIVisualEffectView alloc] initWithEffect:blur];
//    [visualBlur setAlpha:0.7];
//    [visualBlur setFrame:_eventImgView.bounds];
//    [_eventImgView addSubview:visualBlur];
    [_eventImgView setAlpha:0.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
