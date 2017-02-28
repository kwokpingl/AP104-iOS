//
//  InfrastructureAnnotationView.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/26.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface InfrastructureAnnotationView : MKAnnotationView
- (instancetype) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;
@end
