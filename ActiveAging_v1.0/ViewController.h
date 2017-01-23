//
//  ViewController.h
//  EventManagerTest3
//
//  Created by Ga Wai Lau on 1/18/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) UIPanGestureRecognizer *scopeGesture;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;

@end

