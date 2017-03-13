//
//  WeatherClient.m
//  Weather
//
//  Created by Ga Wai Lau on 1/29/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import "WeatherClient.h"
#import "WeatherCondition.h"
#import "WeatherDailyForecast.h"

@interface WeatherClient ()

@property NSURLSession * session;

@end

@implementation WeatherClient

-(id) init {
    if (self = [super init]) {
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    
    return self;
}

#pragma mark - fetchJSONFromURL
- (RACSignal *) fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching: %@", url.absoluteString);
    
    //1
    //Returns the signal. Remember that this will not execute until this signal is subscribed to. -fetchJSONFromURL: creates an object for other methods and objects to use; this behavior is sometimes called the factory pattern
    return [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //2
       NSURLSessionDataTask * dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //Handle retrieved data
           if (!error) {
               NSError * jsonError = nil;
               id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
               
               if (!jsonError) {
                   //1
                   //When JSON data exists and there are no errors, send the subscriber the JSON serialized as either an array or dictionary
                   [subscriber sendNext:json];
               } //end of if (!jsonError)
               else {
                   //2
                   //If there is an error in either case, notify the subscriber
                   [subscriber sendError:jsonError];
               }
           } //end of if (!error)
           
           else {
               //2
               [subscriber sendError:error];
           }
           //3
           [subscriber sendCompleted];
       }];
        
        //3
        //Starts the the network request once someone subscribes to the signal
        [dataTask resume];
        
        //4
        //Creates and returns an RACDisposable object which handles any cleanup when the signal when it is destroyed
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError * _Nonnull error) {
        //5
        //Adds a “side effect” to log any errors that occur. Side effects don’t subscribe to the signal; rather, they return the signal to which they’re attached for method chaining. This is simply adding a side effect that logs on error
        NSLog(@"%@", error);
    }];
}

#pragma mark - Fetch Current Conditions
- (RACSignal *) fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate {
    //1
    NSString * urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lang=zh_tw&lat=%f&lon=%f&units=imperial&APPID=120c951f470b1f1cd37f8008619bed9b", coordinate.latitude, coordinate.longitude];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    //2
    //Use the method you just built to create the signal. Since the returned value is a signal, you can call other ReactiveCocoa methods on it. Here you map the returned value — an instance of NSDictionary — into a different value
    return [[self fetchJSONFromURL:url] map:^(NSDictionary * json) {
        //3
        //Use MTLJSONAdapter to convert the JSON into an WXCondition object, using the MTLJSONSerializing protocol you created for WXCondition
        return [MTLJSONAdapter modelOfClass:[WeatherCondition class] fromJSONDictionary:json error:nil];
    }];
}

#pragma mark - Fetch the hourly forecast
- (RACSignal *) fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    
    NSString * urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lang=zh_tw&lat=%f&lon=%f&units=imperial&cnt=12&APPID=120c951f470b1f1cd37f8008619bed9b", coordinate.latitude, coordinate.longitude];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    //1
    return [[self fetchJSONFromURL:url] map:^(NSDictionary * json) {
        //2
        //Build an RACSequence from the “list” key of the JSON. RACSequences let you perform ReactiveCocoa operations on lists
        RACSequence * list = [json[@"list"] rac_sequence];
        
        //3
        //Map the new list of objects. This calls -map: on each object in the list, returning a list of new objects
        return [[list map:^(NSDictionary * item) {
            
           //4
            //Use MTLJSONAdapter again to convert the JSON into a WXCondition object
            return [MTLJSONAdapter modelOfClass:[WeatherCondition class] fromJSONDictionary:item error:nil];
            
            //5
            //Using -map on RACSequence returns another RACSequence, so use this convenience method to get the data as an NSArray
        }] array];
    }];
}

#pragma mark - fetch the daily forecast
- (RACSignal *) fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {

    NSString * urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lang=zh_tw&units=imperial&cnt=7&lat=%f&lon=%f&APPID=120c951f470b1f1cd37f8008619bed9b", coordinate.latitude, coordinate.longitude];
    
    NSURL * url = [NSURL URLWithString:urlString];
    
    //Use the generic fetch method and map results to convert into an array of Mantle Object
    return [[self fetchJSONFromURL:url] map:^(NSDictionary * json) {
        //Build a sequence from the list of raw JSON
        RACSequence * list = [json[@"list"] rac_sequence];
        
        //use a function to map results from JSON to Mantle object
        return [[list map:^(NSDictionary * item) {
            return [MTLJSONAdapter modelOfClass:[WeatherDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}


@end
