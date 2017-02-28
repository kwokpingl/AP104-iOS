//
//  LocationViewController.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/12.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "LocationViewController.h"
#import "Definitions.h"
#import <MapKit/MapKit.h>
#import "LocationManager.h"
#import "MKMapView+Autoadjustment.h"

@interface LocationViewController () <CLLocationManagerDelegate, MKMapViewDelegate, LocationManagerDelegate>{
    LocationManager * locationMgr;
    CLLocation * eventLocation;
    CLLocationCoordinate2D eventCoordinate;
    MKPointAnnotation * eventAnnotation;
}
@property (weak, nonatomic) IBOutlet UILabel *locationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceTitleLabel;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    locationMgr = [LocationManager shareInstance];
    locationMgr.delegate = self;
    if (locationMgr.accessGranted && !locationMgr.isUpdatingLocation){
        [locationMgr startUpdatingLocation];
    }
    
    _mapView.delegate = self;
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [locationMgr stopUpdatingLocation];
}

-(void)locationControllerDidUpdateLocation:(CLLocation *)location{
    [self mapSetup];
}

- (void) setup{
    [_locationTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_locationTitleLabel setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    NSString * key = EVENT_CITY_KEY;
    [_areaLabel setTextAlignment:NSTextAlignmentLeft];
    [_areaLabel setText:@""];
    if (_eventDetailDict[key] != [NSNull null]){
        [_areaLabel setNumberOfLines:0];
        [_areaLabel setAdjustsFontSizeToFitWidth:true];
        [_areaLabel setText:_eventDetailDict[key]];
    }
    
    key = EVENT_ADDRESS_KEY;
    [_addressLabel setTextAlignment:NSTextAlignmentLeft];
    [_addressLabel setNumberOfLines:0];
    [_addressLabel setText:@""];
    if (_eventDetailDict[key] != [NSNull null]){
        [_addressLabel setText:_eventDetailDict[key]];
        [_addressLabel setAdjustsFontSizeToFitWidth:true];
        [_addressLabel setLineBreakMode:NSLineBreakByWordWrapping];
    }
    
}

- (void) mapSetup {
    if (_eventDetailDict[EVENT_LAT_KEY] != [NSNull null] && _eventDetailDict[EVENT_LON_KEY] != [NSNull null]){
        NSString * lat = _eventDetailDict[EVENT_LAT_KEY];
        NSString * lon = _eventDetailDict[EVENT_LON_KEY];
        eventCoordinate = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
        if (CLLocationCoordinate2DIsValid(eventCoordinate)){
            
            eventAnnotation = [[MKPointAnnotation alloc] init];
            [eventAnnotation setCoordinate:eventCoordinate];
            [eventAnnotation setTitle:_eventDetailDict[EVENT_TITLE_KEY]];
            [eventAnnotation setSubtitle:_eventDetailDict[EVENT_ORGNTION_KEY]];
            
            
            [_mapView setShowsUserLocation:true];
            [_mapView addAnnotation:eventAnnotation];
            [_mapView setRegionBetweenA:eventCoordinate andB:locationMgr.location.coordinate];
            
            double distance = [locationMgr distanceFromLocationUsingLongitude:[lon doubleValue] Latitude:[lat doubleValue]];
            NSString * unit = @"步";
            
            [_distanceLabel setAdjustsFontSizeToFitWidth:true];
            [_distanceLabel setNumberOfLines:0];
            [_distanceLabel setText:[NSString stringWithFormat:@"%.2f %@",distance, unit]];
        }
    }

}



@end
