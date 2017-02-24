//
//  MKMapView+Autoadjustment.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/24.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "MKMapView+Autoadjustment.h"

@implementation MKMapView (Autoadjustment)
- (void) setRegionBetweenA: (CLLocationCoordinate2D) pointA andB: (CLLocationCoordinate2D) pointB{
    
    NSMutableArray * bothPoints = [NSMutableArray new];
    [bothPoints addObject:@[@(pointA.latitude), @(pointA.longitude)]];
    [bothPoints addObject:@[@(pointB.latitude), @(pointB.longitude)]];
    [self recenterMap:bothPoints];
}

- (void) recenterMap: (NSArray *) coordinates {
    CLLocationCoordinate2D maxCoor = {-90.0f,-180.0f};
    CLLocationCoordinate2D minCoor = {90.0f, 180.0f};
    
    for (NSArray * coordinate in coordinates){
        CLLocationCoordinate2D coor = {[coordinate[0] doubleValue], [coordinate[1] doubleValue]};
        
        if (coor.longitude > maxCoor.longitude){
            maxCoor.longitude = coor.longitude;
        }
        if (coor.latitude > maxCoor.latitude){
            maxCoor.latitude = coor.latitude;
        }
        if (coor.longitude < minCoor.longitude){
            minCoor.longitude = coor.longitude;
        }
        if (coor.latitude < minCoor.latitude){
            minCoor.latitude= coor.latitude;
        }
    }
    
    // create the region
    MKCoordinateRegion region = {{0.0f,0.0f},{0.0f,0.0f}};
    region.center.longitude = (minCoor.longitude + maxCoor.longitude)/2.0;
    region.center.latitude = (minCoor.latitude + maxCoor.latitude)/2.0;
    region.span.longitudeDelta = (maxCoor.longitude - minCoor.longitude)+0.02;
    region.span.latitudeDelta = (maxCoor.latitude - minCoor.latitude)+0.02;
    [self setRegion:region animated:true];
}

- (void) locatePointA: (CLLocationCoordinate2D) pointA{
    MKCoordinateSpan span = {0.01, 0.01};
    [self setRegion:MKCoordinateRegionMake(pointA, span) animated:true];
}
@end
