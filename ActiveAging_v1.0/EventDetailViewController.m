//
//  EventDetailViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/22/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventDetailTableViewCell.h"
#import "ServerManager.h"
#import "UserInfo.h"
#import "EventDetailSorter.h"

@interface EventDetailViewController () <UITableViewDelegate, UITableViewDataSource>{
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    NSMutableDictionary * basedKeysMDict;
    NSMutableDictionary * sortedDetailMDict;
    NSMutableArray * basedKeysMArray;
    
    NSInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UITableView *eventDetailTableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@end

@implementation EventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    [_navigationItem setTitle:_eventDetailDict[EVENT_TITLE_KEY]];
    _eventDetailTableView.delegate = self;
    _eventDetailTableView.dataSource = self;
    
    _eventDetailTableView.rowHeight = UITableViewAutomaticDimension;
    _eventDetailTableView.estimatedRowHeight = 200;
    selectedIndex = -1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [self setup];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return basedKeysMArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EventDetailTableViewCell * cell = [_eventDetailTableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.descriptionLabel setAdjustsFontSizeToFitWidth:false];
    [cell.descriptionLabel setNumberOfLines:0];
    cell.titleLabel.text = basedKeysMArray[indexPath.row];
    
    NSArray * tempArray = [[NSArray alloc] initWithArray:sortedDetailMDict[cell.titleLabel.text]];
    NSString * tempStr = @"";
    for (int i = 0; i < tempArray.count; i++){
        
        tempStr = [tempStr stringByAppendingString:[NSString stringWithFormat:@"%@",tempArray[i]]];
        tempStr = [tempStr stringByAppendingString:@"\n"];
        }
    cell.descriptionLabel.text = tempStr;
    
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (selectedIndex == indexPath.row){
        selectedIndex = -1;
    } else {
        selectedIndex = indexPath.row;
    }
    [_eventDetailTableView beginUpdates];
    [_eventDetailTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_eventDetailTableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (selectedIndex == indexPath.row){
        return 300;
    } else {
        return 40;
    }
}

//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewAutomaticDimension;
//}


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
    basedKeysMDict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                       @"organization":@[EVENT_ORGNTION_KEY, EVENT_WEBPAGE_KEY],
                                                                       @"description":@[ EVENT_DESCRIPTION_KEY, EVENT_START_KEY, EVENT_END_KEY],
                                                                       @"registration time": @[EVENT_REG_BEGIN_KEY, EVENT_REG_BEGIN_KEY],
                                                                       @"contact info":@[EVENT_ORGN_NAME_KEY, EVENT_ORGN_PHONE_KEY, EVENT_ORGN_FAX_KEY,EVENT_ORGN_CELL_KEY, EVENT_ORGN_EMAIL_KEY],
                                                                       @"address":@[EVENT_CITY_KEY, EVENT_ADDRESS_KEY, EVENT_LON_KEY, EVENT_LAT_KEY]}];
    basedKeysMArray = [[NSMutableArray alloc] initWithArray:basedKeysMDict.allKeys];
    
    // sort new dictionary
    [EventDetailSorter returnSortedDictionary:_eventDetailDict
                              BasedDictionary:basedKeysMDict
                                     complete:^(NSMutableDictionary *sortedDictionary) {
                                         sortedDetailMDict = [[NSMutableDictionary alloc] initWithDictionary:sortedDictionary];
                                         [_eventDetailTableView reloadData];
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
