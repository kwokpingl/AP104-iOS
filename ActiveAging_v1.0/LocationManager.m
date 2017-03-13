//
//  LocationManager.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/5.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "LocationManager.h"
#import "ServerManager.h"
#import "UserInfo.h"

#define AVERAGE_STRIDE_LENGTH (30*0.0254)

static LocationManager * _myLocationMgr;

@interface LocationManager() <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager * manager;
@property (strong, nonatomic) NSMutableArray * observers;
@end

@implementation LocationManager{
    NSDate * locationMgrStartTime;
    ServerManager * serMgr;
    UserInfo * _userInfo;
}

+ (instancetype) shareInstance {
    if (_myLocationMgr == nil){
        _myLocationMgr = [LocationManager new];
    }
    return _myLocationMgr;
}


- (id) init{
    self = [super init];
    if (self){
        // SETUP CLLocationManager
        _locationMgr = [CLLocationManager new];
        [_locationMgr setDelegate:self];
        
        // check for authorization
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied){
            NSString * title = (status == kCLAuthorizationStatusDenied)?@"定位服務未開啟":@"背景定位未開啟";
            NSString * message = @"請允許背景定位,以使用完整服務.";
            [self showAlertWithTitle:title andMessage:message];
            [self setAccessGranted:false];
        }
        else if (status == kCLAuthorizationStatusNotDetermined){
            if ([_locationMgr respondsToSelector:@selector(requestAlwaysAuthorization)]){
                [_locationMgr requestAlwaysAuthorization];
                [self setAccessGranted:true];
            }
            else{
                NSString * title = @"定位服務未開啟";
                NSString * message = @"請允許背景定位, 以使用完整服務.";
                [self showAlertWithTitle:title andMessage:message];
                [self setAccessGranted:false];
            }
        }
        else {
            
            _locationMgr = [[CLLocationManager alloc] init];
            _locationMgr.delegate = self;
            [_locationMgr setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
            [_locationMgr setDistanceFilter:DISTANCE_FILTER_30M];
            [_locationMgr setAllowsBackgroundLocationUpdates:true];
            [self setAccessGranted:true];
        }
        _isUpdatingLocation = false;
        serMgr = [ServerManager shareInstance];
        
    }
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    if (_location != nil){
        if ([self isValidLocation:locations.lastObject withOldLocation:_location]){
            [self.delegate locationControllerDidUpdateLocation:locations.lastObject];
            [self setLocation:locations.lastObject];
        }
    }
    else{
        [self.delegate locationControllerDidUpdateLocation:locations.lastObject];
        [self setLocation:locations.lastObject];
    }
    
    if ([[UserInfo shareInstance] isShareLocation]){
        _userInfo = [UserInfo shareInstance];
        NSString * lat = [NSString stringWithFormat:@"%.6f", locations.lastObject.coordinate.latitude];
        NSString * lon = [NSString stringWithFormat:@"%.6f", locations.lastObject.coordinate.longitude];
        
        [serMgr updateLocationForAuthorization:@"user" andLat:lat andLon:lon completion:^(NSError *error, id result) {
            if (![result[ECHO_RESULT_KEY] boolValue]){
                NSLog(@"\nUPDATE LOCATION ERROR: %@", error);
            }
            else{
                NSLog(@"\nUPDATE LCOATION SUCCESS");
            }
        }];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"ERROR: %@", error);
}


- (void) startUpdatingLocation {
    if (!_isUpdatingLocation){
        [_locationMgr startUpdatingLocation];
        _isUpdatingLocation = true;
    }
}

- (void) stopUpdatingLocation {
    if (_isUpdatingLocation){
        [_locationMgr stopUpdatingLocation];
        [_locationMgr stopMonitoringSignificantLocationChanges];
        _isUpdatingLocation = false;
    }
}

- (void) showAlertWithTitle: (NSString*) title andMessage: (NSString *) message {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction * setting = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL * settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingURL];
    }];
    
    [alert addAction:ok];
    [alert addAction:setting];
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:true completion:nil];
}


- (double)distanceFromLocationUsingLongitude:(CLLocationDegrees)longitude Latitude:(CLLocationDegrees)latitude{
    
    CLLocation * targetLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    double distanceMeter = [_location distanceFromLocation:targetLocation];
    double distanceInSteps = distanceMeter / AVERAGE_STRIDE_LENGTH;
    return distanceInSteps;
}


#pragma mark - PRIVATE METHOD
/// MARK: Validation_Checker
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

- (void) startMonitoringSignificatnLocationChanges {
    if (!_isUpdatingLocation){
        [_locationMgr startMonitoringSignificantLocationChanges];
        _isUpdatingLocation = !_isUpdatingLocation;
    }
    
}
@end
