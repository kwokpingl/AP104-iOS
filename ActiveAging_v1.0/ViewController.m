//
//  ViewController.m
//  EventManagerTest3
//
//  Created by Ga Wai Lau on 1/18/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import "ViewController.h"
#import "FSCalendar.h"
#import "EventManager.h"
#import <EventKitUI/EventKitUI.h>
#import "CalEventsTableViewCell.h"
#import "EditEventViewController.h"
#import <NotificationCenter/NotificationCenter.h>

static void * __KVOContext;

@interface ViewController () <NCWidgetProviding, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, EKEventEditViewDelegate, UIGestureRecognizerDelegate> {
    
    NSDateFormatter * dateFormatter;
    EventManager * _eventManager;
    EKEventStore * eventStore;
    BOOL isAccessToEventStoreGranted;
    
    NSLocale * locale;
    NSDate * minimumDate;
    NSDate * maximumDate;
    NSDate * chosenDate;
    NSTimeZone * userTimeZone;
//    FSCalendar * calendar;
    NSCalendar * gregorian;
    NSCalendar *lunarCalendar;
    NSArray<NSString *> *lunarChars;
    
    
    NSMutableArray * eventsSpecifications;
    NSMutableArray * allEventsArray;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeight;

@end

@implementation ViewController
#pragma mark - Chinese Calendar
-(void) chineseCalendar {
    self.calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-TW"];
    
    lunarCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    lunarCalendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-TW"];
    
    lunarChars = @[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",@"二一",@"二二",@"二三",@"二四",@"二五",@"二六",@"二七",@"二八",@"二九",@"三十"];
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    _eventManager = [EventManager shareInstance];
    
    _tableView.delegate = self;
    
    eventStore = [EKEventStore new];
    
    [self requestAccessToEventType];
    
    NSString * dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"%@", dateString);
    
    chosenDate = [NSDate date];
    
#pragma mark - UIPanGestureRecognizer setup
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.calendar action:@selector(handleScopeGesture:)];
    
    panGesture.delegate = self;
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 2;
    
    [self.view addGestureRecognizer:panGesture];
    self.scopeGesture = panGesture;
    
    // While the scope gesture begin, the pan gesture of tableView should cancel.
    [self.tableView.panGestureRecognizer requireGestureRecognizerToFail:panGesture];
    
#pragma mark - Calendar Scope set up
    [self.calendar addObserver:self forKeyPath:@"scope" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:__KVOContext];
    
    self.calendar.scope = FSCalendarScopeWeek;
    
    if ([self.extensionContext respondsToSelector:@selector(setWidgetLargestAvailableDisplayMode:)]) {
        
        self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
        
    } else {
        self.preferredContentSize = CGSizeMake(340, self.calendarHeight.constant);
    }
    
//    [self configureLoadView];
    [self chineseCalendar];
//    [self loadEventCalendars];
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

#pragma mark - viewDidAppear
-(void)viewDidAppear:(BOOL)animated{
    [_eventManager sortTimeOrder:chosenDate complete:^(NSMutableArray *eventArray) {
        allEventsArray = [[NSMutableArray alloc] initWithArray:eventArray];
        [self updateAuthorizationStatusToAccessEventStore];
    }];
    
    [super viewDidAppear:animated];
}

/* ============== UpdateAuthorizationStatusToAccessEventStore ================= */
#pragma mark - UpdateAuthorizationStatusToAccessEventStore
- (void) updateAuthorizationStatusToAccessEventStore {
    
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusDenied:
            break;
            
        case EKAuthorizationStatusRestricted: {
            isAccessToEventStoreGranted = false;
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"無法存取" message:@"「哈啦哈啦趣」無法存取您的行事曆。" preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alert animated:YES completion:nil];
            break;
        }
            
        case EKAuthorizationStatusAuthorized: {
            isAccessToEventStoreGranted = true;
            [_tableView reloadData];
            break;
        }
            
        case EKAuthorizationStatusNotDetermined:{
            [_eventManager requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                if (granted){
                    NSLog(@"Granted");
                    _eventManager.eventsAccessGranted = true;
                }else{
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"無法存取" message:@"「哈啦哈啦趣」無法存取您的行事曆。" preferredStyle:UIAlertControllerStyleAlert];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - FSCalendarDataSource
#pragma mark - <FSCalendarDelegate>
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    chosenDate = date;
    
    NSLog(@"did select date %@",[dateFormatter stringFromDate:date]);
    
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    
    NSString * te = [dateFormatter stringFromDate:date];
    NSLog(@"%@", te);
    [_eventManager sortTimeOrder:date complete:^(NSMutableArray *eventArray) {
        allEventsArray = [[NSMutableArray alloc] initWithArray:eventArray];
        [_tableView reloadData];
    }];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    NSLog(@"%s %@", __FUNCTION__, [dateFormatter stringFromDate:calendar.currentPage]);
}

- (void)dealloc
{
    [self.calendar removeObserver:self forKeyPath:@"scope" context:__KVOContext];
    NSLog(@"%s",__FUNCTION__);
}

/* =========================== Widget ========================== */
#pragma mark - Widget
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize
{
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        
        [self.calendar setScope:FSCalendarScopeWeek animated:YES];
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0;
        
    } else if (activeDisplayMode == NCWidgetDisplayModeExpanded) {
        
        [self.calendar setScope:FSCalendarScopeMonth animated:YES];
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.5;
    }
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

#pragma mark - UIColor calendar
- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
    return [gregorian isDateInToday:date] ? appearance.todayColor : nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date
{
    return [UIColor clearColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    return appearance.selectionColor;
}

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    NSInteger day = [lunarCalendar components:NSCalendarUnitDay fromDate:date].day;
    return lunarChars[day-1];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == __KVOContext) {
        FSCalendarScope oldScope = [change[NSKeyValueChangeOldKey] unsignedIntegerValue];
        FSCalendarScope newScope = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        NSLog(@"From %@ to %@",(oldScope == FSCalendarScopeWeek?@"week":@"month"),(newScope == FSCalendarScopeWeek?@"week":@"month"));
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

// Whether scope gesture should begin
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top;
    if (shouldBegin) {
        CGPoint velocity = [self.scopeGesture velocityInView:self.view];
        switch (self.calendar.scope) {
            case FSCalendarScopeMonth:
                return velocity.y < 0;
            case FSCalendarScopeWeek:
                return velocity.y > 0;
        }
    }
    return shouldBegin;
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    _calendarHeight.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}

#pragma mark - TableView
/* =========================== Table View ========================== */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (allEventsArray.count == 0){
        return 1;
    }
    return allEventsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    CalEventsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (allEventsArray.count != 0){
        EKEvent * new = allEventsArray[indexPath.row];
        
        NSDateFormatter * timeFormatter = [NSDateFormatter new];
        timeFormatter.dateFormat = @"HH:mm";
        
        NSString * startDateString = [timeFormatter stringFromDate:new.startDate];
        NSString * endDateString = [timeFormatter stringFromDate:new.endDate];
        
        NSLog(@"am: %@\npm: %@\n", startDateString, endDateString);
        
    
        cell.eventTitle.text = new.title;
        cell.startTimeLabel.text = startDateString;
        cell.endtimeLabel.text = endDateString;
    } else {
        cell.eventTitle.text = @"今天沒有任何活動唷。\n 養足精神，重新出發！";
        cell.startTimeLabel.text = @"";
        cell.endtimeLabel.text = @"";
    }
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"eventDetail" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        FSCalendarScope selectedScope = indexPath.row == 0 ? FSCalendarScopeMonth : FSCalendarScopeWeek;
        [self.calendar setScope:selectedScope animated:YES];
    }
}

#pragma mark - Prepare for Segue (for tableview)
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"eventDetail"]) {
    
//        Configure the destination event view controlle
        EKEventViewController * editEventViewController = (EKEventViewController *) segue.destinationViewController;
        
        //Fetch the index path associated with the selected event
        NSIndexPath * indexPath = _tableView.indexPathForSelectedRow;
        
        //Set the view controller to display the selected event
        
        if (allEventsArray.count != 0){
            editEventViewController.event = allEventsArray[indexPath.row];
        }
        
        //Allow event editing
        editEventViewController.allowsEditing = true;
    }
}

#pragma mark - Add Btn
- (IBAction)addEventBtnPressed:(id)sender {
    
//    Create an instance of EKEventEditViewController
    EKEventEditViewController * addController = [EKEventEditViewController new];
    
    //Set addController's event store to the current event store
    addController.eventStore = _eventManager;
//    addController.event = nil;
    
    //Set addcontroller viewdelegate
    addController.editViewDelegate = self;
    
//    [self performSegueWithIdentifier:@"ChangeViewController" sender:sender];
    [self presentViewController:addController animated:YES completion:nil];
}

#pragma mark - EKEventEditViewDelegate
// Overriding EKEventEditViewDelegate method to update event store according to user actions.
-(void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    
    ViewController * __weak weakSelf = self;
    
    //Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (action != EKEventEditViewActionCanceled) {
            dispatch_async(dispatch_get_main_queue(), ^{
               
                //Re-fetch all events happening in the next 24 hrs
                 [_eventManager sortTimeOrder:[NSDate date] complete:^(NSMutableArray *eventArray) {
                     
                 }];
                
                //Update the UI with the above events
                [weakSelf.tableView reloadData];
                
            }); //end of dispatch_async
        } // end of if (action != EKEventEditViewActionCanceled)
    }]; // end of self dismiss
}

//Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar
-(EKCalendar *) eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
    
    return _eventManager.defaultCalendar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
