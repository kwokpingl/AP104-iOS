//
//  CustomAnnotationView.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/16.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "CustomAnnotationView.h"

@interface CustomAnnotationView()

@property (nonatomic) CGFloat width;

@end

@implementation CustomAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self){
        UILabel * label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont boldSystemFontOfSize:10]];
        [label setTextColor:[UIColor whiteColor]];
        [self setLabel:label];
        
        
    }
    return self;
}

#pragma mark - PRIVATE METHODs
- (void) adjustLabelWidth: (id<MKAnnotation>) annotation {
    NSString * title;
    if ([annotation respondsToSelector:@selector(title)] && _label){
        title = [annotation title];
        NSDictionary * attributes = @{NSFontAttributeName: _label.font};
        CGSize size = [title sizeWithAttributes:attributes];
        _width = MAX(size.width+6, 22);
    }
    else {
        _width = 22;
    }
    
    [_label setFrame: CGRectMake(0, 33, _width, 10)];
    [_label setText:title];
    [self setFrame: CGRectMake(self.frame.origin.x, self.frame.origin.y, _width, 44)];
}

- (void)drawRect:(CGRect)rect {
    CGFloat lineWidth = 1.0;
    CGFloat radius = 10 + lineWidth/2.0;
    CGFloat bubbleHeight = 20;
    CGPoint point = CGPointMake(_width/2.0, 31);
    CGPoint nextPoint;
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:point];
    
    nextPoint = CGPointMake(point.x - radius, point.y - bubbleHeight);
    [path addCurveToPoint:nextPoint controlPoint1:CGPointMake(point.x, point.y + bubbleHeight/2.0) controlPoint2:CGPointMake(nextPoint.x, nextPoint.y - bubbleHeight/2.0)];
    
    [[UIColor blackColor] setStroke];
    [[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.8] setFill];
    
    path.lineWidth = lineWidth;
    
    [path fill];
    [path stroke];
    
//    []
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
