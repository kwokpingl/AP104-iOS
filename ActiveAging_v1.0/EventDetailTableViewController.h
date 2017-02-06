//
//  EventDetailTableViewController.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/23/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailTableViewController : UIViewController
@property (nonatomic, strong) NSMutableDictionary * eventDetailDict;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *joinButton;
@property (nonatomic, strong) UIImage * eventImg;
@end
