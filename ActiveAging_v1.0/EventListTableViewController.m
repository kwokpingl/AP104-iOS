//
//  EventListTableViewController.m
//  EventManagerTest3
//
//  Created by Ga Wai Lau on 1/22/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import "EventListTableViewController.h"
#import "EventListTableViewCell.h"
#import "SQLite3DBManager.h"
#import "EventManager.h"
#import "EventDetailViewController.h"

#define EVENTS_TABLE_NAME @"EventsList"
#define SQLITE_FILENAME @"eventsList.sql"

@interface EventListTableViewController () <UITableViewDelegate, UITableViewDataSource> {
    SQLite3DBManager * dbManager;
    NSDictionary * eventsListDictionary;
    NSArray * eventData;
    EventManager * _eventManager;
    NSInteger titleIndex, startDateTimeIndex, endDateTimeIndex, locationIndex, detailIndex;
}
//@property (strong, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation EventListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _eventManager = [EventManager shareInstance];
    
    dbManager = [[SQLite3DBManager alloc] initWithDatabaseFilename:SQLITE_FILENAME];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    NSString * titleStr = @"What a Beautiful Day";
    NSString * startDateTimeStr = @"2017-02-02 08:00";
    NSString * endDateTimeStr = @"2017-02-03 08:00";
    NSString * detailStr = @"Let''s go out and eat";
    NSString * locationStr = @"Tapei City";
    
    NSString * query = [NSString stringWithFormat:@"insert into %@ values (null,'%@','%@','%@','%@','%@')", EVENTS_TABLE_NAME, titleStr, startDateTimeStr, endDateTimeStr, detailStr, locationStr];
    
    [dbManager executeQuery:query];
    
    if (dbManager.sqlError != nil){
        NSLog(@"ERROR: %@", dbManager.sqlError);
    }
    
    NSString * secondTitleStr = @"Another Beautiful Day";
    NSString * secondStartDateTimeStr = @"2017-02-02 08:00";
    NSString * secondEndDateTimeStr = @"2017-02-03 08:00";
    NSString * secondDetailStr = @"Let''s go out and eat";
    NSString * secondLocationStr = @"Tapei City";
    
    query = [NSString stringWithFormat:@"insert into %@ values (null, '%@','%@','%@','%@','%@')", EVENTS_TABLE_NAME, secondTitleStr, secondStartDateTimeStr, secondEndDateTimeStr, secondDetailStr, secondLocationStr];
    
    [dbManager executeQuery:query];
}

-(void) viewWillAppear:(BOOL)animated {
    
    dbManager = [[SQLite3DBManager alloc] initWithDatabaseFilename:SQLITE_FILENAME];
    
    [self loadInfo];
}

#pragma mark - loadInfo
-(void) loadInfo {
    //Load info from dbManager
    NSString * query = [NSString stringWithFormat:@"select * from %@", EVENTS_TABLE_NAME];
    eventData = [dbManager loadDataFromDB:query];

}

#pragma mark - Table view data source
/* =========================== Table View ========================== */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return eventData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    titleIndex = [dbManager.arrColumnNames indexOfObject:@"title"];
    startDateTimeIndex = [dbManager.arrColumnNames indexOfObject:@"startDateTime"];
   
    // Configure the cell...
    [self loadInfo];
    cell.titleLabel.text = eventData[indexPath.row][titleIndex];
    cell.startDateTimeLabel.text = eventData[indexPath.row][startDateTimeIndex];
    cell.joinBtn.tag = indexPath.row;
    
    [cell.joinBtn setEnabled:true];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


#pragma mark - Request access
-(void) requestAccessToEventType {
    [_eventManager requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"無法存取" message:@"「哈啦哈啦趣」無法存取您的行事曆。" preferredStyle:UIAlertControllerStyleAlert];
                
                [self presentViewController:alert animated:YES completion:nil];
            });
            
            return;
        }
        
        if (error)
        {
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark - Join Btn
- (IBAction)joinBtnPressed:(UIButton *)sender {
    [self requestAccessToEventType];
    
    startDateTimeIndex = [dbManager.arrColumnNames indexOfObject:@"startDateTime"];
    endDateTimeIndex = [dbManager.arrColumnNames indexOfObject:@"endDateTime"];
    titleIndex = [dbManager.arrColumnNames indexOfObject:@"title"];
    locationIndex = [dbManager.arrColumnNames indexOfObject:@"location"];
    detailIndex = [dbManager.arrColumnNames indexOfObject:@"detail"];

    NSArray* joinEvent = eventData[sender.tag];
    
    NSDictionary * eventDetail = @{@"startDateTime":joinEvent[startDateTimeIndex],
                                   @"endDateTime": joinEvent[endDateTimeIndex],
                                   @"title": joinEvent[titleIndex],
                                   @"location": joinEvent[locationIndex],
                                   @"detail": joinEvent[detailIndex]
                                   };
    
    [_eventManager newEventToBeAdded:eventDetail complete:^(NSMutableArray *eventArray) {
        
        [self isNewEventAdded:([eventArray[0] intValue] == 1)?true:false];
    }];
}

-(void) isNewEventAdded: (BOOL) isAdded {
    if (isAdded) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"耶！存好了。" message:@"您可以在月曆上瀏覽新增的活動喔。" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:UIAlertActionStyleDefault];
        
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"哇~沒存到。" message:@"你這段時間已經有活動了唷。" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"好，我知道了。" style:UIAlertActionStyleDefault handler:UIAlertActionStyleDefault];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    EventListTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    EventDetailViewController * vc = [segue destinationViewController];
    vc.titleIndex = [dbManager.arrColumnNames indexOfObject:@"title"];
    vc.startDateIndex = [dbManager.arrColumnNames indexOfObject:@"startDateTime"];
    vc.endDateIndex = [dbManager.arrColumnNames indexOfObject:@"endDateTime"];
    vc.locationIndex = [dbManager.arrColumnNames indexOfObject:@"location"];
    vc.detailIndex = [dbManager.arrColumnNames indexOfObject:@"detail"];
    
    vc.event = [[NSArray alloc] initWithArray:eventData[indexPath.row]];
}


@end
