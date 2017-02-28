//
//  EventDetailViewController.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/12.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EventDetailViewControllerDelegate <NSObject>
- (void) updateList;
@end

@interface EventDetailViewController : UIViewController
@property (strong, nonatomic) NSMutableDictionary * eventDetailDict;
@property (assign, nonatomic) id<EventDetailViewControllerDelegate> delegate;
@end
