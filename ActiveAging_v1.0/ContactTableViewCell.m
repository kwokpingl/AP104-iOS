//
//  ContactTableViewCell.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/1.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell
@synthesize imageView=_imageView;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
