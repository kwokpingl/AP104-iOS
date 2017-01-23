//
//  FSCalendarDelegationProxy.h
//  Pods
//
//  Created by Ga Wai Lau on 1/13/17.
//
//Copyright © 2016 Wenchao Ding. All rights reserved.

#import <Foundation/Foundation.h>
#import "FSCalendar.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSCalendarDelegationProxy : NSProxy

@property (weak  , nonatomic) id delegation;
@property (strong, nonatomic) Protocol *protocol;
@property (strong, nonatomic) NSDictionary<NSString *,NSString *> *deprecations;

- (instancetype)init;
- (SEL)deprecatedSelectorOfSelector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
