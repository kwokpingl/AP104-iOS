//
//  WeatherManager.m
//  Weather
//
//  Created by Ga Wai Lau on 1/29/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import "WeatherManager.h"
#import "WeatherClient.h"
#import "LocationManager.h"
#import <TSMessage.h>



@interface WeatherManager ()<LocationManagerDelegate>

//declare as readwrite to change the values behind the scenes
@property (nonatomic, strong, readwrite) WeatherCondition * currentCondition;
@property (nonatomic, readwrite) CLLocation * currentLocation;
@property (nonatomic, readwrite) NSArray * hourlyForecast;
@property (nonatomic, readwrite) NSArray * dailyForecast;
@property CLLocationManager * locationManager;
@property (nonatomic, strong) LocationManager * locationMgr;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WeatherClient * client;

@end

@implementation WeatherManager

+ (instancetype) sharedManager {
    static id _shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [WeatherManager new];
    });
    
    return _shareManager;
}

- (id) init {
    if (self = [super init]) {
        //1

        _locationMgr = [LocationManager shareInstance];
        _locationMgr.delegate = self;
        
        //2
        //Creates the WXClient object for the manager. This handles all networking and data parsing
        _client = [WeatherClient new];
        
        //3
        //The manager observes the currentLocation key on itself using a ReactiveCocoa macro which returns a signal
        [[[[RACObserve(self, currentLocation)
         //4
         ignore:nil]
        
        //5
        //Flatten and subscribe to all 3 signals when currentLocation updates
           //-flattenMap: is very similar to -map:, but instead of mapping each value, it flattens the values and returns one object containing all three signals. In this way, you can consider all three processes as a single unit of work
           flattenMap: ^(CLLocation * newLocation) {
               return [RACSignal merge:@[
                                  [self updateCurrentConditions],
                                  [self updateDailyForecast],
                                  [self updateHourlyForecast]
                                  ]];
        
        //6
        //Deliver the signal to subscribers on the main thread
    }] deliverOn: RACScheduler.mainThreadScheduler]
         
         //7
         subscribeError:^(NSError * error) {
             [TSMessage showNotificationWithTitle:@"Error"
                                         subtitle:@"There was a problem fetching the latest weather."  type: TSMessageNotificationTypeError];
         }];
    }
    return self;
}

#pragma mark - trigger weather fetching when a location is found
- (void) findCurrentLocation {
    self.isFirstUpdate = YES;
    [_locationMgr startUpdatingLocation];
}

-(void)locationControllerDidUpdateLocation:(CLLocation *)location{
    
    //2
    if (location.horizontalAccuracy > 0) {
        //3
        [_locationMgr stopUpdatingLocation];
        self.currentLocation = location;
    }
}


- (RACSignal *) updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:_currentLocation.coordinate]
            doNext:^(WeatherCondition * condition) {
                self.currentCondition = condition;
            }];
}

- (RACSignal *) updateHourlyForecast {
    return [[self.client fetchHourlyForecastForLocation:_currentLocation.coordinate]
            doNext:^(NSArray * conditions) {
    self.hourlyForecast = conditions;
    }];
}

- (RACSignal *) updateDailyForecast {
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray * conditions) {
                self.dailyForecast = conditions;
            }];
}

@end
