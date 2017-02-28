//
//  InfrastructureAnnotationView.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/26.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "InfrastructureAnnotationView.h"

@implementation InfrastructureAnnotationView

- (instancetype) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if ([reuseIdentifier isEqualToString:@"hospital"]){
        [self setImage:[UIImage imageNamed:@"Hospital Annotation"]];
    }
    else if ([reuseIdentifier isEqualToString:@"police"]){
        [self setImage:[UIImage imageNamed:@"Police Station Annotation"]];
    }
    
    [self setCanShowCallout:true];
    
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
