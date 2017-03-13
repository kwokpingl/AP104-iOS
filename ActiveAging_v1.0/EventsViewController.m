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
#import "ImageManager.h"
#import "DateManager.h"

#define VIEW_TO_TOP 50
#define VIEW_TO_BOTTOM 60
#define VIEW_HEIGHT  (self.view.frame.size.height - VIEW_TO_TOP - VIEW_TO_BOTTOM)
#define PICKER_HEIGHT 200.0
#define BUTTON_WIDTH 100.0
#define BUTTON_TO_CONTAINER 5.0
#define BUTTON_HEIGHT (50.0)
#define LOCATIONS_EN @[@"All",@"New Taipei", @"Kaohsiung", @"Taichung", @"Taipei", @"Taoyuan", @"Tainan", @"Hsinchu", @"Keelung", @"Chiayi", @"Changhua", @"Pingtung", @"Zhubei", @"Yuanlin", @"Douliu", @"Taitung", @"Hualien", @"Toufen", @"Nantou", @"Yilan", @"Miaoli", @"Magong", @"Puzi", @"Taibao"]
#define LOCATIONS_ZH @[@"全部", @"新北市", @"高雄市", @"臺中市", @"臺北市", @"桃園市", @"臺南市", @"新竹市", @"基隆市", @"嘉義市", @"彰化市", @"屏東市", @"竹北市", @"員林市", @"斗六市", @"臺東市", @"花蓮市", @"頭份市", @"南投市", @"宜蘭市", @"苗栗市", @"馬公市", @"朴子市", @"太保市"]

@interface EventsViewController ()<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>{
    
    NSMutableArray * locationEventArray;
    NSMutableArray * locationsArray;
    NSMutableArray * currentArray;
    NSDictionary * eventsDict;
    
    NSMutableDictionary * locationsDictionary;
    NSMutableDictionary * allEventJoinBased;
    
    UIRefreshControl * refreshControl;
    ServerManager * _serverMgr;
    NSInteger targetLocation;
    NSString * currentPage;
    UserInfo * _userInfo;
    
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
    
    NSLog(@"TestViewController Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef) self));
    
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    [_tableView setTableFooterView: [UITableViewHeaderFooterView new]];
    [_tableView setSeparatorColor:[UIColor blackColor]];
    [_tableView setDataSource: self];
    [_tableView setDelegate: self];
    
    currentPage = @"notJoined";
    
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithTitle:@"回活動頁面"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:nil
                                                                   action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    [self updateEvents];
    refreshControl = [UIRefreshControl new];
    [refreshControl setBackgroundColor:[UIColor purpleColor]];
    [refreshControl setTintColor:[UIColor whiteColor]];
    [refreshControl addTarget:self action:@selector(updateEvents) forControlEvents:UIControlEventValueChanged];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10) {
        _tableView.refreshControl = refreshControl;
    } else {
        _tableView.backgroundView = refreshControl;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    // start loading the data and reload tableview
    
}


#pragma mark- TABLEVIEW_METHODS
// MARK: BASIC_SETUP
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return locationEventArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EventTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    // CELL SETUP
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // EVENT TITLE
    [cell.eventTitleLabel setNumberOfLines:0];
    [cell.eventTitleLabel setFont:[UIFont systemFontOfSize:25]];
    [cell.eventTitleLabel setAdjustsFontSizeToFitWidth:true];
    [cell.eventTitleLabel setText:locationEventArray[indexPath.row][EVENT_TITLE_KEY]];
    
    // EVENT ORGANIZATION
    [cell.eventOrganizationLabel setNumberOfLines:0];
    [cell.eventOrganizationLabel setFont:[UIFont systemFontOfSize:25]];
    [cell.eventOrganizationLabel setAdjustsFontSizeToFitWidth:true];
    [cell.eventOrganizationLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.eventOrganizationLabel setTextAlignment:NSTextAlignmentLeft];
    [cell.eventOrganizationLabel setText:locationEventArray[indexPath.row][EVENT_ORGNTION_KEY]];
    
    // EVENT LOCATION LABEL
    [cell.eventLocationLabel setText:locationEventArray[indexPath.row][EVENT_CITY_KEY]];
    [cell.eventLocationLabel setFont:[UIFont systemFontOfSize:25]];
    [cell.eventLocationLabel setAdjustsFontSizeToFitWidth:true];
    [cell.eventLocationLabel setNumberOfLines:0];
    
    // EVENT DATE
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:DATE_FORMAT];
    NSString * formattedDate;
    formattedDate = [DateManager convertDateOnly:locationEventArray[indexPath.row][EVENT_START_KEY] withFormatter:formatter];

    [cell.eventRegistrationDateLabel setTextColor:[UIColor blueColor]];
    [cell.eventRegistrationDateLabel setText:formattedDate];
    
    
    // SET IMAGE
    NSString * imageName = locationEventArray[indexPath.row][EVENT_PIC_KEY];
    
    [ImageManager getEventImage:imageName completion:^(NSError *error, id result) {
        if (!error){
            [cell.eventImgView setContentMode:UIViewContentModeScaleAspectFit];
            [cell.eventImgView.layer setCornerRadius:cell.eventImgView.frame.size.width/2.0];
            [cell.eventImgView setClipsToBounds:true];
            cell.eventImgView.image = [UIImage imageWithData:result];
        } else {
            cell.eventImgView.image = nil;
        }
    }];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    EventDetailViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    vc.eventDetailDict = [NSMutableDictionary new];
    [vc.navigationItem setLeftItemsSupplementBackButton:true];
    [vc.eventDetailDict addEntriesFromDictionary:locationEventArray[indexPath.row]];
    [vc setDelegate:self];
    [self.navigationController pushViewController:vc animated:true];
}


#pragma mark - BUTTONS --- NEED MODIFICATION
- (IBAction)locationButtonPressed:(id)sender {
    [self setupPickerView];
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
    [self getEvents:sender];
}


- (void) cancelButtonPressed {
    [self.view.subviews.lastObject removeFromSuperview];
}

#pragma mark - PRIVATE METHOD
- (void) updateEvents{
    [_serverMgr retrieveEventInfo:USER_EVENT_FETCH UserID:_userInfo.getUserID EventID:@"-1" completion:^(NSError *error, id result) {
        if ([result[ECHO_RESULT_KEY] boolValue]){
            eventsDict = [[NSDictionary alloc] initWithDictionary:result[@"message"]];
            locationEventArray = [eventsDict[currentPage] mutableCopy];
            
            NSLocale * locale = [NSLocale currentLocale];
            NSString * languagCode = [locale objectForKey:NSLocaleLanguageCode];
            
            if ([languagCode containsString:@"zh"]){
                [self setNumberOfEvents:LOCATIONS_ZH];
            }
            else {
                [self setNumberOfEvents:LOCATIONS_EN];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView setEstimatedRowHeight:100];
                [_tableView setRowHeight:UITableViewAutomaticDimension];
                targetLocation = 0;
                [_tableView reloadData];
                [refreshControl endRefreshing];
            });
        }
    }];
}

// FETCH the EVENTS based on _currentPage
- (void) getEvents: (id) sender {
    locationEventArray = [NSMutableArray new];
    
    if (targetLocation == 0){
        locationEventArray = [eventsDict[currentPage] mutableCopy];
    }
    else{
        for (NSDictionary * event in eventsDict[currentPage]){
            if ([event[EVENT_CITY_KEY] caseInsensitiveCompare:LOCATIONS_EN[targetLocation]] == NSOrderedSame){
                [locationEventArray addObject:event];
            }
        }
    }
    [_tableView reloadData];
    if ([sender isKindOfClass:[UIButton class]]){
        if ([((UIButton *) sender).titleLabel.text isEqualToString:@"OK"]){
            [self.view.subviews.lastObject removeFromSuperview];
        }
    }
}



#pragma mark - PICKERVIEW
/// MARK: SETUPs and INFO
// SET the ARRAY to show the Cities along with NUMBER OF EVENTS
// ie CITY (5)
- (void) setNumberOfEvents:(NSArray *) LOCATIONS {
    locationsDictionary = [NSMutableDictionary new];
    for (NSString * key in eventsDict){
        NSMutableArray * locationEvents = [NSMutableArray new];
        [locationEvents addObject:LOCATIONS[0]];
        for (int i = 1; i < LOCATIONS_EN.count ; i++){
            NSInteger counter = 0;
            for (NSDictionary * eventDetail in eventsDict[key]){
                if ([LOCATIONS_EN[i] caseInsensitiveCompare:eventDetail[EVENT_CITY_KEY]] == NSOrderedSame){
                    counter ++;
                }
            }
            [locationEvents addObject:[NSString stringWithFormat:@"%@ (%ld)", LOCATIONS[i], counter]];
        }
        [locationsDictionary setObject:locationEvents forKey:key];
    }
}


- (void) setupPickerView {
    
    // show a picker
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_TO_TOP, self.view.frame.size.width, VIEW_HEIGHT)];
    UIButton * ok = [[UIButton alloc] initWithFrame:CGRectMake(view.frame.size.width -BUTTON_WIDTH - BUTTON_TO_CONTAINER, 60 - VIEW_TO_TOP, BUTTON_WIDTH, BUTTON_HEIGHT)];
    UIButton * cancel = [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_TO_CONTAINER, 60 - VIEW_TO_TOP, BUTTON_WIDTH, BUTTON_HEIGHT)];
    UIPickerView * locationPicker = [[UIPickerView alloc] initWithFrame:CGRectMake( 0, cancel.frame.origin.y + BUTTON_HEIGHT + BUTTON_TO_CONTAINER, view.frame.size.width, view.frame.size.height - cancel.frame.origin.y - BUTTON_HEIGHT - BUTTON_TO_CONTAINER)];
    
    if (!UIAccessibilityIsReduceTransparencyEnabled()){
        [view setBackgroundColor:[UIColor clearColor]];
        
        // ADD BLUR EFFECT
        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView * blurViewEffect = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [blurViewEffect setFrame:view.bounds];
        [blurViewEffect setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [view addSubview:blurViewEffect];
    }
    else{
        [view setBackgroundColor:[UIColor whiteColor]];
    }
    
    [ok setTitle:@"OK" forState:UIControlStateNormal];
    [ok setBackgroundColor:[UIColor blackColor]];
    [ok addTarget:self action:@selector(getEvents:) forControlEvents:UIControlEventTouchUpInside];
    
    [cancel setTitle:@"CANCEL" forState:UIControlStateNormal];
    [cancel setBackgroundColor:[UIColor blackColor]];
    [cancel addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:ok];
    [view addSubview:cancel];
    [view addSubview:locationPicker];
    [self.view addSubview:view];
    
    [locationPicker setDataSource:self];
    [locationPicker setDelegate:self];
    [locationPicker selectRow:targetLocation inComponent:0 animated:false];
    [self pickerView:locationPicker didSelectRow:targetLocation inComponent:0];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return LOCATIONS_EN.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 60.0;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString * title = locationsDictionary[currentPage][row];
    
    NSDictionary * attsDict = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:25] forKey:NSFontAttributeName];
    NSMutableAttributedString * returnTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:attsDict];
    
    return returnTitle;
}
/// MARK: DELEGATES
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    targetLocation = row;
}

- (void) updateList {
    [self updateEvents];
}

- (void)dealloc {
    NSLog(@"TestViewController Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef) self));
}

@end
