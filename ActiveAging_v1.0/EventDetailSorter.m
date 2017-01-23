//
//  EventDetailSorter.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/23/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventDetailSorter.h"

@implementation EventDetailSorter
+ (void)returnSortedDictionary:(NSDictionary *)unsortedDic
               BasedDictionary:(NSMutableDictionary *)basedDictionary
                      complete:(DictionarySorter) finalMDict{
    
    NSMutableDictionary * resultDictionary = [NSMutableDictionary new];
    
    for (NSString * key in basedDictionary.allKeys){
        NSMutableArray * tempMutableArray = [NSMutableArray new];
        NSArray * tempArray = [[NSArray alloc] initWithArray:basedDictionary[key]];
        
        for (int i = 0; i < tempArray.count; i++){
            [tempMutableArray addObject:unsortedDic[tempArray[i]]];
        }
        
        [resultDictionary setObject:tempMutableArray forKey:key];
    }
    
    finalMDict(resultDictionary);
    
}

+ (void) returnArrayWithDictionaryFrom:(NSDictionary *) unsortedDict
                         KeyDictionary:(NSMutableDictionary *)keyDictionary
                              complete: (ArraySorter) finalMArray{
    // keyDictionary {MY_SORTING_KEYS:[DATABASE_KEYS]}
    // finalMArray [{MY_SORTING_KEYS: {DATABSE_KEYS: VALUE}}]
    
    NSMutableArray * returnArray = [NSMutableArray new];
    NSMutableDictionary * innerDictionary = [NSMutableDictionary new];
    
    for (NSString * key in keyDictionary.allKeys){
        
        NSArray * tempArray = [[NSArray alloc] initWithArray:keyDictionary[key]];
        
        NSMutableDictionary * tempDict = [NSMutableDictionary new];
        for (int i = 0; i < tempArray.count; i++){
            NSString * dataKey = tempArray[i];
            [tempDict setObject:unsortedDict[dataKey] forKey:dataKey];
        }
        
        [innerDictionary setObject:tempDict forKey:key];
    }
    [returnArray addObject:innerDictionary];
    finalMArray(returnArray);
}
@end
