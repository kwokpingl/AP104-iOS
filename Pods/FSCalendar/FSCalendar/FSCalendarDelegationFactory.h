//
//  FSCalendarDelegationFactory.h
//  Pods
//
//  Created by Ga Wai Lau on 1/13/17.
//
//

#import <Foundation/Foundation.h>
#import "FSCalendarDelegationProxy.h"

@interface FSCalendarDelegationFactory : NSObject

+ (FSCalendarDelegationProxy *)dataSourceProxy;
+ (FSCalendarDelegationProxy *)delegateProxy;

@end

