//
//  EventTableViewCell.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/22/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *eventImgView;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventOrganizationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventRegistrationDateLabel;
@end
