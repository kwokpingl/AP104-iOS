//
//  WeatherCondition.h
//  Weather
//
//  Created by Ga Wai Lau on 1/29/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface WeatherCondition : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSNumber * humidity;
@property (nonatomic, strong) NSNumber * temperature;
@property (nonatomic, strong) NSNumber * tempHigh;
@property (nonatomic, strong) NSNumber * tempLow;
@property (nonatomic, strong) NSString * locationName;
@property (nonatomic, strong) NSDate * sunrise;
@property (nonatomic, strong) NSDate * sunset;
@property (nonatomic, strong) NSString * conditionDescription;
@property (nonatomic, strong) NSString * condition;
@property (nonatomic, strong) NSNumber * windBearing;
@property (nonatomic, strong) NSNumber * windSpeed;
@property (nonatomic, strong) NSString * icon;
//@property (nonatomic, strong) NSString * id;

-(NSString *) imageName;

@end
