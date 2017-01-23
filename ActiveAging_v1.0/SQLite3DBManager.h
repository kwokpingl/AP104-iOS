//
//  SQLite3DBManager.h
//  FindMyFriends2
//
//  Created by Ga Wai Lau on 1/2/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLite3DBManager : NSObject

-(instancetype) initWithDatabaseFilename: (NSString *) dbFilename;

@property (nonatomic, strong) NSMutableArray * arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;
@property (nonatomic, strong) NSString * sqlError;
-(NSArray *) loadDataFromDB:(NSString *) query;

-(void) executeQuery:(NSString *) query;

@end
