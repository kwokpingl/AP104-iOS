//
//  ContactTableViewCell.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/1.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel * titleLabel;
@property (strong, nonatomic) IBOutlet UILabel * subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView * imageView;

@end
