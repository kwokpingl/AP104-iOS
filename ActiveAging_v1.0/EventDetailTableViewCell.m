//
//  EventDetailTableViewCell.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/23/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventDetailTableViewCell.h"
static int showDetail;
@implementation EventDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    showDetail = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    showDetail ++;
    if (showDetail >1){
        showDetail = 0;
    }
    _descriptionViewHeight.priority = (showDetail==1)?250:999;
    NSLog(@"HEIGHT: %.2f", _descriptionView.frame.size.height);
    NSLog(@"PRIORITY : %f", _descriptionViewHeight.priority);
}

@end
