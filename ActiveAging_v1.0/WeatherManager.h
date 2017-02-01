//
//  WeatherManager.h
//  Weather
//
//  Created by Ga Wai Lau on 1/29/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <ReactiveObjC.h>
#import "WeatherCondition.h"

@interface WeatherManager : NSObject <CLLocationManagerDelegate>

+ (instancetype) sharedManager;

@property (nonatomic, strong, readonly) CLLocation * currentLocation;
@property (nonatomic, strong, readonly) WeatherCondition * currentCondition;
@property (nonatomic, strong, readonly) NSArray * hourlyForecast;
@property (nonatomic, strong, readonly) NSArray * dailyForecast;

- (void) findCurrentLocation;

@end
