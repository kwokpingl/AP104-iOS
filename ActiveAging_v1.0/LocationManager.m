//
//  LocationManager.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/5.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager() <CLLocationManagerDelegate>

@end

@implementation LocationManager{
    NSDate * locationMgrStartTime;
}

+ (LocationManager *) shareInstance {
    static LocationManager * instance = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        instance = [[LocationManager alloc] init];
    });
    
    return instance;
}

- (id) init {
    self = [super init];
    
    if (!_locationMgr){
        _locationMgr = [CLLocationManager new];
        
        if ([_locationMgr respondsToSelector:@selector(requestAlwaysAuthorization)]){
            [_locationMgr requestAlwaysAuthorization];
        }
        
        [_locationMgr setDesiredAccuracy:kCLLocationAccuracyBest];
        [_locationMgr setDistanceFilter:100]; // meters
        [_locationMgr setAllowsBackgroundLocationUpdates:true];
        [_locationMgr setDelegate:self];
        _numberOfObserver = 0;
    }
    return self;
}

- (void) startUpdatingLocation {
    NSLog(@"START UPDATING");
    _numberOfObserver ++;
    if (_numberOfObserver > 0){
        [_locationMgr startUpdatingLocation];
        locationMgrStartTime = [NSDate date];
    }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"LOCATION FAILED: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations{
    CLLocation * location = locations.lastObject;
    NSLog(@"Latitude %+.6f, Longitude %+.6f\n",
          location.coordinate.latitude,
          location.coordinate.longitude);
    
    if ([self isValidLocation:location withOldLocation:_currentLocation]){
        _currentLocation = location;
    } else {
        NSLog(@"NOT VALID");
    }
}

- (void) stopUpdatingLocation {
    NSLog(@"STOP UPDATING");
    _numberOfObserver --;
    if (_numberOfObserver == 0){
        [_locationMgr stopUpdatingLocation];
    }
}

- (double)distanceFromLocationUsingLongitude:(CLLocationDegrees)longitude Latitude:(CLLocationDegrees)latitude{
    
    CLLocation * targetLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    double distanceMeter = [_currentLocation distanceFromLocation:targetLocation];
    double distanceKilo = distanceMeter/1000.0;
    return distanceKilo;
}


- (UIAlertController *) permissionAlert {
    UIAlertController * alert;
    UIAlertAction * ok;
    NSString * alertTitle;
    NSString * alertMessage;
    NSString * okMessage;
    UIAlertControllerStyle alertStyle;
    
    alertTitle = @"偵測到錯誤";
    alertMessage = @"請允許我們用您的定位系統以便讓您享用我們ＡＰＰ的完整服務";
    okMessage = @"OK";
    alertStyle = UIAlertControllerStyleAlert;
    
    alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:alertStyle];
    ok = [UIAlertAction actionWithTitle:okMessage style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    
    return alert;
}

- (UIAlertController *) serviceEnableAlert {
    UIAlertController * alert;
    UIAlertAction * ok;
    NSString * alertTitle;
    NSString * alertMessage;
    NSString * okMessage;
    UIAlertControllerStyle alertStyle;
    
    alertTitle = @"偵測到錯誤";
    alertMessage = @"請開啟您的定位功能以便讓您享用我們ＡＰＰ的完整服務";
    okMessage = @"OK";
    alertStyle = UIAlertControllerStyleAlert;
    
    alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:alertStyle];
    ok = [UIAlertAction actionWithTitle:okMessage style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    
    return alert;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse){
        
    }
}

- (BOOL) isValidLocation: (CLLocation *) newLocation withOldLocation: (CLLocation *) oldLocation{
    if (!newLocation){
        return false;
    }
    
    if (newLocation.horizontalAccuracy < 0){
        return false;
    }
    
    NSTimeInterval secondsSinceLastPoint = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
    
    if (secondsSinceLastPoint < 0){
        return false;
    }
    
    NSTimeInterval secondsAfterInitiation = [newLocation.timestamp timeIntervalSinceDate:locationMgrStartTime];
    
    if (secondsAfterInitiation < 0){
        return false;
    }
    
    
    return true;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentLocation"]){
        NSLog(@"Latitude %+.6f, Longitude %+.6f\n",
                            _currentLocation.coordinate.latitude,
                            _currentLocation.coordinate.longitude);
            }
}

@end
