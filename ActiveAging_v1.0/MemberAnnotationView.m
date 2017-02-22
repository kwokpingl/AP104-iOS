//
//  MemberAnnotationView.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/19.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "MemberAnnotationView.h"

@interface MemberAnnotationView()

@end

@implementation MemberAnnotationView

- (instancetype) initWithAnnotation:(id<MKAnnotation>)annotation distance:(float) distance {
    self = [super initWithAnnotation:annotation reuseIdentifier:nil];
    
    [self setCanShowCallout:true];
//    [self setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    
    _distance = distance;
    
    if (distance <= 1.0){
        self.image = [UIImage imageNamed:@"1kmAnnotation"];
    }
    else if (distance > 1.0 && distance <= 5.0){
        self.image = [UIImage imageNamed:@"5kmAnnotation"];
    }
    else{
        self.image = [UIImage imageNamed:@"otherAnnotation"];
    }
    return self;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView * hitTest = [super hitTest:point withEvent:event];
    
    if (hitTest != nil){
        [self.superview bringSubviewToFront:self];
    }
    return hitTest;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if (isInside) {
        for (UIView * view in self.subviews){
            isInside = CGRectContainsPoint(view.frame, point);
            if (isInside){
                break;
            }
        }
    }
    return isInside;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
