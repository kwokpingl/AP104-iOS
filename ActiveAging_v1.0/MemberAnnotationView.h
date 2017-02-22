//
//  MemberAnnotationView.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/19.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MemberAnnotationView : MKAnnotationView
@property float distance;

- (instancetype) initWithAnnotation:(id<MKAnnotation>)annotation distance: (float) distance;


@end
