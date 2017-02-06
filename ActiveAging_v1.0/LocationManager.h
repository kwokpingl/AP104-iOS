//
//  LocationManager.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/5.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface LocationManager : NSObject
@property (nonatomic, strong) CLLocationManager * locationMgr;
@property (nonatomic, strong) CLLocation * currentLocation;
@property (nonatomic) int numberOfObserver;

+ (LocationManager*) shareInstance;
- (void) startUpdatingLocation;
- (void) stopUpdatingLocation;
- (double) distanceFromLocationUsingLongitude: (CLLocationDegrees) longitude Latitude: (CLLocationDegrees) latitude;
- (UIAlertController *) serviceEnableAlert;
- (UIAlertController *) permissionAlert;
@end
