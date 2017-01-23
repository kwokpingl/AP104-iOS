//
//  EventsTableViewCell.h
//  EventManagerTest3
//
//  Created by Ga Wai Lau on 1/20/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalEventsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *endtimeLabel;

@end
