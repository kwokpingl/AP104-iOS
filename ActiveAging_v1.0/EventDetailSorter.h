//
//  EventDetailSorter.h
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/23/17.
//  Copyright © 2017 PING. All rights reserved.
//



#import <Foundation/Foundation.h>
typedef void (^DictionarySorter)(NSMutableDictionary * sortedDictionary);
typedef void (^ArraySorter)(NSMutableArray * sortedArray);

@interface EventDetailSorter : NSObject
+ (void) returnSortedDictionary: (NSDictionary *) unsortedDic
                BasedDictionary: (NSMutableDictionary *) basedDictionary
                       complete:(DictionarySorter)finalMDict;

+ (void) returnArrayWithDictionaryFrom:(NSDictionary *) unsortedDict
                         KeyDictionary:(NSMutableDictionary *)keyDictionary
                              complete: (ArraySorter) finalMArray;
@end
