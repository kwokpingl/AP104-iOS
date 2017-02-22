//
//  TrackerButton.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/18.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface TrackerButton : UIButton
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@end
