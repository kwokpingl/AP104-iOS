//
//  LocationManager.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/5.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "Definitions.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol LocationManagerDelegate <NSObject>
- (void) locationControllerDidUpdateLocation: (CLLocation *) location;
@optional
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;
@end


@interface LocationManager : NSObject
@property (strong, nonatomic) CLLocationManager * locationMgr;
@property (strong, nonatomic) CLLocation * location;
@property (nonatomic) BOOL accessGranted;
@property (nonatomic) BOOL isUpdatingLocation;
@property (weak, nonatomic) id delegate;

+ (instancetype) shareInstance;
- (void) startUpdatingLocation;
- (void) startUpdatingHeading;
- (void) stopUpdatingLocation;
- (void) stopUpdatingHeading;
- (void) startMonitoringSignificatnLocationChanges;

- (double) distanceFromLocationUsingLongitude: (CLLocationDegrees) longitude Latitude: (CLLocationDegrees) latitude;
@end
