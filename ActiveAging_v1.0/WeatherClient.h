//
//  WeatherClient.h
//  Weather
//
//  Created by Ga Wai Lau on 1/29/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <ReactiveObjC.h>

@import Foundation;

@interface WeatherClient : NSObject

- (RACSignal *) fetchJSONFromURL: (NSURL *) url;
- (RACSignal *) fetchCurrentConditionsForLocation: (CLLocationCoordinate2D) coordinate;
- (RACSignal *) fetchHourlyForecastForLocation: (CLLocationCoordinate2D) coordinate;
- (RACSignal *) fetchDailyForecastForLocation: (CLLocationCoordinate2D) coordinate;

@end
