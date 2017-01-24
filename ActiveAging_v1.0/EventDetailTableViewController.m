//
//  EventDetailTableViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/23/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventDetailTableViewController.h"
#import "ServerManager.h"
#import "UserInfo.h"
#import "EventDetailSorter.h"
#import "EventManager.h"
#import "EventDetailOuterTableViewCell.h"
#import "EventDetailInnerTableViewCell.h"

@interface EventDetailTableViewController ()<UITableViewDelegate, UITableViewDataSource>{
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    EventManager * _eventManager;
    NSMutableDictionary * basedKeysMDict;
    NSMutableDictionary * sortedDetailMDict;
    NSMutableArray * sortedDetailMArray;
    NSMutableArray * basedKeysMArray;
    
    NSInteger selectedIndex;
    
//    UIButton * joinButton;
//    UIBarButtonItem * joinBarButton;
}
@property (weak, nonatomic) IBOutlet UITableView *outerTableView;
//@property (weak, nonatomic) IBOutlet UITableView *innerTableView;



@end

@implementation EventDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    _eventManager = [EventManager shareInstance];
    
    [self.navigationItem setTitle:_eventDetailDict[EVENT_TITLE_KEY]];
    
    // SET DELEGATE
    _outerTableView.delegate = self;
    _outerTableView.dataSource = self;
//    _innerTableView.delegate = self;
//    _innerTableView.dataSource = self;
    
    _outerTableView.rowHeight = UITableViewAutomaticDimension;
    selectedIndex = -1;
    
//    joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [joinButton setTitle:@"有興趣" forState:UIControlStateNormal];
//    [joinButton setTitleEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//    [joinButton setTintColor:[UIColor blackColor]];
//    [joinButton sizeToFit];
//    [joinButton setFrame:CGRectMake(0, self.view.frame.size.width-40, 30, 30)];
//    [joinButton addTarget:self action:@selector(joinBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    joinBarButton = [[UIBarButtonItem alloc] initWithCustomView:joinButton];
//    self.navigationItem.leftBarButtonItem =joinBarButton;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [self setup];
}

#pragma mark - TABLE_VIEW
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
//    _outerTableView.
    return basedKeysMArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    EventDetailOuterTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString * category = basedKeysMArray[indexPath.row];
    NSDictionary * categoryDict = sortedDetailMArray[0][category];
//    NSDictionary * categoryDict = categoryArray[0];
    
    NSString * tempStr = @"";
    int i = 0;
    for (NSString * key in categoryDict.allKeys){
        NSString * value = categoryDict[key];
        if (value != (NSString *)[NSNull null]){
            
            if([key isEqualToString:EVENT_START_KEY] || [key isEqualToString:EVENT_END_KEY]){
                NSDateFormatter * dateFormat = [NSDateFormatter new];
                [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                
                NSDate * date = [dateFormat dateFromString:value];
                [dateFormat setDateFormat:@"YYYY-MM-dd"];
                value = [dateFormat stringFromDate:date];
                value = [@""stringByAppendingString:value];
            }
            
            tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"%@ ", value]];
            i++;
        }
    }
    [cell.OuterTopContentTitleLabel setLineBreakMode:NSLineBreakByClipping];
    [cell.OuterContentView setAutoresizesSubviews:true];
    cell.OuterTopContentTitleLabel.text = tempStr;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (selectedIndex == indexPath.row){
        selectedIndex = -1;
    } else {
        selectedIndex = indexPath.row;
    }
    [_outerTableView beginUpdates];
    [_outerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_outerTableView endUpdates];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (selectedIndex == indexPath.row){
        return 100;
    }else{
        return 40;
    }
}


- (IBAction)joinBtnPressed:(id)sender {
    // check calendar
    NSString * action;
    
    // add events
    if ([_joinButton.title isEqualToString:@"有興趣"]){
        action = USER_EVENT_JOIN;
    }else {
        action = USER_EVENT_QUIT;
    }
        [_serverMgr retrieveEventInfo:action
                                UserID:[_userInfo getUserID]
                               EventID:_eventDetailDict[EVENT_ID_KEY]
                            completion:^(NSError *error, id result) {
                                NSString * alertTitle, * alertMessage;
                                if ([result[@"result"] boolValue]){
                                    
                                    alertTitle = @"SUCCESS";
                                    alertMessage = @"請與舉辦單位聯繫以完成加入活動手續。";
                                    
                                    if ([action isEqualToString:USER_EVENT_JOIN]){
                                        [self requestAccessToEventType];
                                        
                                        NSDictionary * eventDetail = @{@"startDateTime":_eventDetailDict[EVENT_START_KEY],
                                                                       @"endDateTime": _eventDetailDict[EVENT_END_KEY],
                                                                       @"title": _eventDetailDict[EVENT_TITLE_KEY],
                                                                       @"location": _eventDetailDict[EVENT_ADDRESS_KEY],
                                                                       @"detail": _eventDetailDict[EVENT_DESCRIPTION_KEY]
                                                                       };
                                        [_eventManager newEventToBeAdded:eventDetail complete:^(NSMutableArray *eventArray) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                               [self isNewEventAdded:([eventArray[0] intValue] == 1)?true:false];
                                            });
                                            
                                        }];
                                    }
                                    
                                } else{
                                    alertTitle = @"Failed";
                                    alertMessage = @"Something went wrong";
                                }
                                
                                UIAlertController * alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                [alert addAction:ok];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self presentViewController:alert animated:true completion:nil];
                                    if ([_joinButton.title isEqualToString:@"有興趣"]){
                                        [_joinButton setTitle:@"沒興趣"];
                                    } else {
                                        [_joinButton setTitle:@"有興趣"];
                                    }
                                });
        }];
    
    
    
    
}

#pragma mark - CALENDAR METHODS
// MARK: REQUEST_ACCESS_TO_EVENT_TYPE
-(void) requestAccessToEventType {
    [_eventManager requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"無法存取" message:@"「哈啦哈啦趣」無法存取您的行事曆喔，請允許我們使用您的日曆。" preferredStyle:UIAlertControllerStyleAlert];
                
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

// MARK: CHECK_IF_EVENT_IS_ADDED
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



#pragma mark - PRIVATE_METHOD
// MARK: SETMETHOD
- (void) setup{
    // SETUP THE KEYS
    /*
     pic 圖檔
     organization 舉辦單位
     description  資訊
     registration time 報名期間
     contact info 聯絡方式
     address 地址
     */
    basedKeysMDict = [[NSMutableDictionary alloc]
                      initWithDictionary:@{
                                           @"organization":@[EVENT_ORGNTION_KEY, EVENT_WEBPAGE_KEY],
                                           @"description":@[ EVENT_DESCRIPTION_KEY, EVENT_START_KEY, EVENT_END_KEY],
                                           @"registration time": @[EVENT_REG_BEGIN_KEY, EVENT_REG_BEGIN_KEY],
                                           @"contact info":@[EVENT_ORGN_NAME_KEY, EVENT_ORGN_PHONE_KEY, EVENT_ORGN_FAX_KEY,EVENT_ORGN_CELL_KEY, EVENT_ORGN_EMAIL_KEY],
                                           @"address":@[EVENT_CITY_KEY, EVENT_ADDRESS_KEY, EVENT_LON_KEY, EVENT_LAT_KEY]
                                           }];
    
    basedKeysMArray = [[NSMutableArray alloc] initWithArray:basedKeysMDict.allKeys];
    
    // sort new dictionary
    [EventDetailSorter returnArrayWithDictionaryFrom:_eventDetailDict KeyDictionary:basedKeysMDict complete:^(NSMutableArray *sortedArray) {
        sortedDetailMArray = [[NSMutableArray alloc] initWithArray:sortedArray];
        [_outerTableView reloadData];
    }];
    
    
//    [EventDetailSorter
//     returnSortedDictionary:_eventDetailDict
//     BasedDictionary:basedKeysMDict
//     complete:^(NSMutableDictionary *sortedDictionary) {
//         sortedDetailMDict = [[NSMutableDictionary alloc] initWithDictionary:sortedDictionary];
//         [_outerTableView reloadData];
//         [_innerTableView reloadData];
//     }];
    
    // SET PICTURE
    
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
