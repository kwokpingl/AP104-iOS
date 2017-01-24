//
//  EventDetailOuterTableViewCell.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/23/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventDetailOuterTableViewCell.h"
#import <UIKit/UIKit.h>

static int showDetail;

@implementation EventDetailOuterTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    

    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    showDetail ++;
    if (showDetail > 1){
        showDetail = 0;
    }
    _OuterBottomContentHeightContraint.priority = (showDetail==1)?250:999;
}


-(void)layoutSubviews{
    [super layoutSubviews];
}







@end
