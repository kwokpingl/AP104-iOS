//
//  NSDictionary+MTLJSONKeyPath.m
//  Mantle
//
//  Created by Robert Böhnke on 19/03/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "NSDictionary+MTLJSONKeyPath.h"

#import "MTLJSONAdapter.h"

@implementation NSDictionary (MTLJSONKeyPath)

- (id)mtl_valueForJSONKeyPath:(NSString *)JSONKeyPath success:(BOOL *)success error:(NSError **)error {
    NSArray *components = [JSONKeyPath componentsSeparatedByString:@"."];
    
//    NSLog(@"JSONKeyPath: %@", JSONKeyPath);
    
    id result = self;
    for (NSString *component in components) {
        // Check the result before resolving the key path component to not
        // affect the last value of the path.
        if (result == nil || result == NSNull.null) break;
        
        //        if ([result isKindOfClass:[NSArray class]]){
        //            result = [result firstObject];
        //        }
        
        if (![result isKindOfClass:NSDictionary.class] ) {
            if (error != NULL) {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid JSON dictionary", @""),
                                           NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"JSON key path %1$@ could not resolved because an incompatible JSON dictionary was supplied: \"%2$@\"", @""), JSONKeyPath, self]
                                           };
                
                *error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorInvalidJSONDictionary userInfo:userInfo];
            }
            
            if (success != NULL) *success = NO;
            
            return nil;
        }
        
        //        if ([result isKindOfClass:[NSArray class]]){
        //            result = result[0][component];
        //        }else{
        //           result = result[component];
        //        }
        result = result[component];
    }
    
    if (success != NULL) *success = YES;
    
    if ([components.firstObject isEqualToString:@"temp"] || [components.lastObject isEqualToString:@"temp"] ||[components.lastObject isEqualToString:@"temp_max"] ||[components.lastObject isEqualToString:@"temp_min"] ){
        result = [self convertToDegreeCelFromF:result];
//        NSLog(@"%@",result);
    }
    return result;
}

- (id) convertToDegreeCelFromF:(id) degreeF{
    double degreeC =([degreeF doubleValue]-32.0) * 5.0/9.0;
    NSNumber * result = [NSNumber numberWithDouble:degreeC];
    return result;
}
@end
