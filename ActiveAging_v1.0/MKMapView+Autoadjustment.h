//
//  MKMapView+Autoadjustment.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/24.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (Autoadjustment)
- (void) setRegionBetweenA: (CLLocationCoordinate2D) pointA andB: (CLLocationCoordinate2D) pointB;
- (void) recenterMap: (NSArray *) coordinates;
- (void) locatePointA: (CLLocationCoordinate2D) pointA;
@end
