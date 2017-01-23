//
//  EventsViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/22/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventsViewController.h"
#import "EventTableViewCell.h"
#import "ServerManager.h" // retrieveEventInfo
#import "UserInfo.h"



@interface EventsViewController ()<UITableViewDelegate, UITableViewDataSource>{
    
    NSDictionary * eventsDict;
    NSArray * eventsArray;
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    NSString * currentPage;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *eventRecordButton;
@end

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    currentPage = @"notJoined";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    // start loading the data
    [_serverMgr retrieveEventInfo:USER_EVENT_FETCH UserID:_userInfo.getUserID EventID:@"" completion:^(NSError *error, id result) {
        if ([result[@"result"] boolValue]){
            eventsDict = [[NSDictionary alloc] initWithDictionary:result[@"message"]];
            [_tableView reloadData];
        }
    }];
    
    // then reload Table
}


#pragma mark- TABLEVIEW_METHODS
// MARK: BASIC_SETUP
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    eventsArray = [[NSArray alloc] initWithArray:eventsDict[currentPage]];
    return eventsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EventTableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.eventTitleLabel.text = eventsArray[indexPath.row][EVENT_TITLE_KEY];
    // also image
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    EventTableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    NSString * cellTitle = cell.eventTitleLabel.text;
    
    if ([cellTitle isEqualToString:eventsArray[indexPath.row][EVENT_TITLE_KEY]]){
        cell.eventTitleLabel.text = eventsArray[indexPath.row][EVENT_REG_BEGIN_KEY];
    } else {
        cell.eventTitleLabel.text = eventsArray[indexPath.row][EVENT_TITLE_KEY];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (IBAction)locationButtonPressed:(id)sender {
    
    
    
}

- (IBAction)recordButtonPressed:(id)sender {
    if ([currentPage isEqualToString:@"notJoined"]){
        currentPage = @"joined";
    } else {
        currentPage = @"notJoined";
    }
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
