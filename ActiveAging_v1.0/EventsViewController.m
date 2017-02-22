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
#import "EventDetailViewController.h"
#import "ImageManager.h"
#import "DateManager.h"


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
    
    self.tableView.tableFooterView = [UITableView new];
    
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithTitle:@"回活動頁面" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    // start loading the data and reload tableview
    [self updateEvents];
    [_tableView setEstimatedRowHeight:100];
    [_tableView setRowHeight:UITableViewAutomaticDimension];
}


#pragma mark- TABLEVIEW_METHODS
// MARK: BASIC_SETUP
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    eventsArray = [[NSArray alloc] initWithArray:eventsDict[currentPage]];
    
    return eventsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EventTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
//    cell.preservesSuperviewLayoutMargins = false;
//    cell.separatorInset = UIEdgeInsetsZero;
//    cell.layoutMargins = UIEdgeInsetsZero;

    
    // EVENT TITLE
    [cell.eventTitleLabel setNumberOfLines:0];
    cell.eventTitleLabel.text = eventsArray[indexPath.row][EVENT_TITLE_KEY];
    
    // EVENT ORGANIZATION
    [cell.eventOrganizationLabel setNumberOfLines:0];
    [cell.eventOrganizationLabel sizeToFit];
    [cell.eventOrganizationLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.eventOrganizationLabel setTextAlignment:NSTextAlignmentLeft];
    [cell.eventOrganizationLabel.layer setBorderWidth:0.3];
    [[cell.eventOrganizationLabel layer] setCornerRadius:3.0];
    [cell.eventOrganizationLabel setText:eventsArray[indexPath.row][EVENT_ORGNTION_KEY]];
    
    // EVENT DATE
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:DATE_FORMAT];
    NSString * formattedDate;
    formattedDate = [DateManager convertDateOnly:eventsArray[indexPath.row][EVENT_START_KEY] withFormatter:formatter];

    [cell.eventRegistrationDateLabel setTextColor:[UIColor blueColor]];
    [cell.eventRegistrationDateLabel setText:formattedDate];
    
    // SET IMAGE
    NSString * imageName = eventsArray[indexPath.row][EVENT_PIC_KEY];
    
    [ImageManager getEventImage:imageName completion:^(NSError *error, id result) {
        if (!error){
            [cell.eventImgView setContentMode:UIViewContentModeScaleAspectFit];
            [cell.eventImgView.layer setCornerRadius:cell.eventImgView.frame.size.width/2.0];
//            [cell.eventImgView.layer setMasksToBounds:true];
            [cell.eventImgView setClipsToBounds:true];
            cell.eventImgView.image = [UIImage imageWithData:result];
        } else {
            cell.eventImgView.image = nil;
        }
    }];
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    [self performSegueWithIdentifier:@"eventDetail" sender:indexPath];
    EventDetailViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    vc.eventDetailDict = [NSMutableDictionary new];
    [vc.navigationItem setLeftItemsSupplementBackButton:true];
    [vc.eventDetailDict addEntriesFromDictionary:eventsArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:true];
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
        EventDetailViewController * vc = [segue destinationViewController];
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
