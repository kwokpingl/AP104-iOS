//
//  MapViewController.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/24/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+Autoadjustment.h"

@interface MapViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@end
