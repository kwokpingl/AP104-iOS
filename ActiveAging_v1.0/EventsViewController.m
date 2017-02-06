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
//#import "EventDetailViewController.h"
#import "EventDetailTableViewController.h"
#import "ImageManager.h"


@interface EventsViewController ()<UITableViewDelegate, UITableViewDataSource>{
    
    NSDictionary * eventsDict;
    NSArray * eventsArray;
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    NSString * currentPage;
}
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
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
    // start loading the data and reload tableview
    [self updateEvents];
}


#pragma mark- TABLEVIEW_METHODS
// MARK: BASIC_SETUP
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    eventsArray = [[NSArray alloc] initWithArray:eventsDict[currentPage]];
    
    return eventsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EventTableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    
    cell.eventTitleLabel.text = eventsArray[indexPath.row][EVENT_TITLE_KEY];
    // also image
    
    NSString * imageName = eventsArray[indexPath.row][EVENT_PIC_KEY];
    
    [ImageManager getEventImage:imageName completion:^(NSError *error, id result) {
        if (!error){
            cell.eventImgView.image = [UIImage imageWithData:result];
        } else {
            cell.eventImgView.image = nil;
        }
    }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    EventTableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    NSString * cellTitle = cell.eventTitleLabel.text;
    
    if ([cellTitle isEqualToString:eventsArray[indexPath.row][EVENT_TITLE_KEY]]){
        NSString * message = [NSString stringWithFormat:@"報名日期: %@",eventsArray[indexPath.row][EVENT_REG_BEGIN_KEY]];
        cell.eventTitleLabel.text = message;
    } else {
        cell.eventTitleLabel.text = eventsArray[indexPath.row][EVENT_TITLE_KEY];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"eventDetail" sender:indexPath];
    
}

#pragma mark - BUTTONS --- NEED MODIFICATION
- (IBAction)locationButtonPressed:(id)sender {
    // show a picker
    
    
}

- (IBAction)recordButtonPressed:(id)sender {
    if ([currentPage isEqualToString:@"notJoined"]){
        currentPage = @"joined";
        [_eventRecordButton setTitle: @"最新活動"
                            forState:UIControlStateNormal];
    } else {
        currentPage = @"notJoined";
        [_eventRecordButton setTitle: @"活動記錄"
                            forState:UIControlStateNormal];
    }
    [_tableView reloadData];
}

#pragma mark - SEGUE
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"eventDetail"]){
        EventDetailTableViewController * vc = [segue destinationViewController];
        NSIndexPath * indexPath = (NSIndexPath *) sender;
        vc.eventDetailDict = [NSMutableDictionary new];
        [vc.eventDetailDict addEntriesFromDictionary:eventsArray[indexPath.row]];
    }
}


#pragma mark - PRIVATE METHOD
- (void) updateEvents{
    [_serverMgr retrieveEventInfo:USER_EVENT_FETCH UserID:_userInfo.getUserID EventID:@"-1" completion:^(NSError *error, id result) {
        if ([result[@"result"] boolValue]){
            eventsDict = [[NSDictionary alloc] initWithDictionary:result[@"message"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
    }];
}


@end
