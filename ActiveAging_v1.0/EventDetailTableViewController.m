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
#import "EventDetailOuterTableViewCell.h"
#import "EventDetailInnerTableViewCell.h"

@interface EventDetailTableViewController ()<UITableViewDelegate, UITableViewDataSource>{
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    NSMutableDictionary * basedKeysMDict;
    NSMutableDictionary * sortedDetailMDict;
    NSMutableArray * basedKeysMArray;
    
    NSInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *outerTableView;
@property (weak, nonatomic) IBOutlet UITableView *innerTableView;

@end

@implementation EventDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    [self.navigationItem setTitle:_eventDetailDict[EVENT_TITLE_KEY]];
    
    // SET DELEGATE
    _outerTableView.delegate = self;
    _outerTableView.dataSource = self;
    _innerTableView.delegate = self;
    _innerTableView.dataSource = self;
    
    _outerTableView.rowHeight = UITableViewAutomaticDimension;
    selectedIndex = -1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
}

#pragma mark - TABLE_VIEW
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _outerTableView){
        return basedKeysMDict
    }
    
    if (tableView == _innerTableView){
        
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
        
    }];
    
    
    [EventDetailSorter
     returnSortedDictionary:_eventDetailDict
     BasedDictionary:basedKeysMDict
     complete:^(NSMutableDictionary *sortedDictionary) {
         sortedDetailMDict = [[NSMutableDictionary alloc] initWithDictionary:sortedDictionary];
         [_outerTableView reloadData];
         [_innerTableView reloadData];
     }];
    
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
