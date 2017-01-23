//
//  EventDetailOuterTableViewCell.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/23/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailOuterTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *OuterContentView;
@property (weak, nonatomic) IBOutlet UIView *OuterTopContentView;
@property (weak, nonatomic) IBOutlet UILabel *OuterTopContentTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *OuterBottomContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *OuterBottomContentHeightContraint;
@property (weak, nonatomic) IBOutlet UITableView *InnerTableView;
@end
