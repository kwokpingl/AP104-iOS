//
//  EventListTableViewCell.h
//  EventManagerTest3
//
//  Created by Ga Wai Lau on 1/22/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *startDateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinBtn;

@end
