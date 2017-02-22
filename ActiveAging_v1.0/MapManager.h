//
//  MapManager.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/14.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapManager : NSObject
+ (MKCoordinateRegion) setRegionBetweenA: (CLLocationCoordinate2D) pointA andB: (CLLocationCoordinate2D) pointB;
+ (MKCoordinateRegion) recenterMap: (NSArray *) coordinates;
+ (MKCoordinateRegion) locatePointA: (CLLocationCoordinate2D) pointA;
@end
