//
//  WidgetEventTableViewCell.m
//  ActiveAging_v1.0
//
//  Created by Ga Wai Lau on 2/13/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "WidgetEventTableViewCell.h"

@implementation WidgetEventTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_timeLabel setFont:[UIFont systemFontOfSize:25]];
    [_timeLabel setAdjustsFontSizeToFitWidth:true];
    [_timeLabel setNumberOfLines:0];
    
    [_titleLabel setFont:[UIFont systemFontOfSize:25]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
