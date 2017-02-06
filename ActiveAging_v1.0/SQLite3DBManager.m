//
//  SQLite3DBManager.m
//  FindMyFriends2
//
//  Created by Ga Wai Lau on 1/2/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import "SQLite3DBManager.h"
#import <sqlite3.h>
#import "EventListTableViewController.h"

@interface SQLite3DBManager()

@property (nonatomic, strong) NSString * eventsDirectory;
@property (nonatomic, strong) NSString * databaseFilename;
@property (nonatomic, strong) NSMutableArray * eventsList;
//
//-(void)copyDatabaseintoDocumentsDirectory;
-(void) runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;

@end

@implementation SQLite3DBManager

-(instancetype) initWithDatabaseFilename:(NSString *)dbFilename {
    self = [super init];
    
    if (self) {
        //Set the documents directory path to the historyDirectory properly
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
        self.eventsDirectory = [paths objectAtIndex:0];
        NSLog(@"DIRECTORY: %@", self.eventsDirectory);
        //Keep the database filename
        self.databaseFilename = dbFilename;
    }
    return self;
}

-(void) runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable {
    
    //Create a sqlite object
    sqlite3 * sqlite3Database;
    
    //Set the database file path
    NSString * databasePath = [self.eventsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    //Initialize the results array
    if (self.eventsList != nil) {
        [self.eventsList removeAllObjects];
        self.eventsList = nil;
    }
    self.eventsList = [NSMutableArray new];
    
    //Initialize the column names array
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [NSMutableArray new];
    
    //Open the database
    int openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if (openDatabaseResult == SQLITE_OK) {
        //Declare a sqlite3_stmt object in which will be stored in the query after having been compiled into a SQLite statment
        sqlite3_stmt * compiledStatement;
        
        //Load all data from database to memory
        int prepareStatmentResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if (prepareStatmentResult == SQLITE_OK) {
            //In this case data must be loaded from the database
            
            if(!queryExecutable){
                //Declare an array to keep the data for each fetched row
                NSMutableArray * arrDataRow;
            
                //Loop through the results and add them to the result array row by row
                while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    //Initialize the mutable array that will contain the data of a fetched row
                    arrDataRow = [NSMutableArray new];
                
                    //Get the total number of columns
                    int totalColumns = sqlite3_column_count(compiledStatement);
                
                    //Go through all columns and fetch each column data
                    for (int i = 0; i < totalColumns ; i++) {
                        //Convert the column data to text
                        char * dbDataAsChars = (char *) sqlite3_column_text(compiledStatement, i);
                        
                        //If there are contents in the current column then add them to the current row array
                        if (dbDataAsChars != NULL) {
                            //Convert the characters to string
                            [arrDataRow addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        
                        //Keep the current column name
                            if (self.arrColumnNames.count != totalColumns) {
                                dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                                [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                            }
                        } // end of if dbDataAsChars != NULL
                    } //end of for loop

            //Store each fetched data row in the results array, but first check if there is actutally data
                    if (arrDataRow.count > 0) {
                        [self.eventsList addObject:arrDataRow];
                    }
                } // End of while sqlite3_step(compiledStatement) == SQLITE_ROW
            } // End of if Not Executable
        
            else {
                //This is the case of an executable query
                
                //Execute the query
                int executeQueryResults = sqlite3_step(compiledStatement);
                
                if (executeQueryResults == SQLITE_DONE) {
                    //Keep the affected rows
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    // Keep the last inserted row ID
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
            
                }
                else {
                    //If could not execute the query show the error msg
                    _sqlError = [NSString stringWithUTF8String:sqlite3_errmsg(sqlite3Database)];
//                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                } // end of executeQueryResult == SQLITE_DONE
                
            } // end of if Executable
            
        } //end of (if doCompileStatement)
    
        else {
            //If the database cannot be opened then show the error message on the debugger
            _sqlError = [NSString stringWithUTF8String:sqlite3_errmsg(sqlite3Database)];
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        //Release the compiled statment from memory
        sqlite3_finalize(compiledStatement);
        
    } //end of if (openDatabaseResult)
    
    //Close the database
    sqlite3_close(sqlite3Database);
    
} //end of runQuery

-(NSArray *)loadDataFromDB:(NSString *)query {
    //Run the query and indicate that is not executable
    //The query string is converted to a char* object
    [self runQuery:[query UTF8String] isQueryExecutable:false];
    
    //Returned the loaded results
    return (NSArray *)self.eventsList;
}

-(void)executeQuery:(NSString *)query {
    //Run the query and indicate that is executable
    [self runQuery:[query UTF8String] isQueryExecutable:true];
}

@end
