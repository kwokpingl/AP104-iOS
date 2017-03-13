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
    
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_imageView setFrame:CGRectMake(10, 5, self.frame.size.width/5.0, self.frame.size.height-20)];
    [_titleLabel setFrame:CGRectMake(10, _imageView.frame.size.width+5, self.frame.size.width*3.0/5.0, self.frame.size.height-20)];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
