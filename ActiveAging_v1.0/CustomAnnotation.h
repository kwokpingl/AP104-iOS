//
//  CustomAnnotation.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/26.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotation : MKPlacemark

@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * subtitle;
@property (strong, nonatomic) NSString * phone;
@property (strong, nonatomic) NSString * type;

@end
