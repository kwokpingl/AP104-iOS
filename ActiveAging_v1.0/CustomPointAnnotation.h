//
//  CustomPointAnnotation.h
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/26.
//  Copyright © 2017年 PING. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomPointAnnotation : MKPointAnnotation

@property (strong, nonatomic) NSString * address;
@property (strong, nonatomic) NSString * phone;
@property (strong, nonatomic) UIImage * image;
@property (strong, nonatomic) NSString * type;
@end
