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
#import "Definitions.h"
#import "Widget.h"

#define WIDGET_NAME @"group.ActiveAging.TodayExtensionSharingDefaults"

static void * __KVOContext;

@interface ViewController () <NCWidgetProviding, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, EKEventEditViewDelegate, UIGestureRecognizerDelegate> {
    
    NSDateFormatter * dateFormatter;
    EventManager * _eventManager;
    EKEventStore * eventStore;
    BOOL isAccessToEventStoreGranted;
    
    NSLocale * locale;
    NSDate * chosenDate;
    NSTimeZone * userTimeZone;
    NSCalendar * gregorian;
    NSCalendar *lunarCalendar;
    NSArray<NSString *> *lunarChars;
    
    NSMutableArray * eventsSpecifications;
    NSMutableArray * allEventsArray;
    
    NSDictionary * newEvent;
    EKEvent * addNewevent;
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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    self.tableView.tableFooterView = [UITableView new];
    
/// MARK: date and data setup
    dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    _eventManager = [EventManager shareInstance];
    _calendar.delegate = self;
    _calendar.dataSource = self;
    [self fsCalendarSetUp];
    _tableView.delegate = self;
    
    eventStore = [EKEventStore new];
    gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    [self requestAccessToEventType];
    
    chosenDate = [NSDate date];
    
/// MARK: UIPanGestureRecognizer setup
    _scopeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.calendar action:@selector(handleScopeGesture:)];
    _scopeGesture.minimumNumberOfTouches = 1;
    _scopeGesture.maximumNumberOfTouches = 2;
    _scopeGesture.delegate = self;
    [self.view addGestureRecognizer:_scopeGesture];
    [_calendar addObserver:self forKeyPath:@"scope" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:__KVOContext];
    /// MARK: Calendar Scope set up
    
    // While the scope gesture begin, the pan gesture of tableView should cancel.
    [self.tableView.panGestureRecognizer requireGestureRecognizerToFail:_scopeGesture];
    [self chineseCalendar];
    [Widget widgetConfigurationWithTemperature:nil conditions:nil complete:^(NSError *error, id result) {
        
    }];
}

#pragma mark - viewWillAppear
-(void)viewWillAppear:(BOOL)animated{
    [_eventManager sortTimeOrder:chosenDate complete:^(NSMutableArray *eventArray) {
        allEventsArray = [[NSMutableArray alloc] initWithArray:eventArray];
        [self updateAuthorizationStatusToAccessEventStore];
    }];
    self.navigationController.toolbar.hidden = true;
}

- (void) viewDidAppear:(BOOL)animated {
    [_calendar reloadData];
    [_calendar.calendarHeaderView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.navigationController.toolbar.hidden = false;
}

- (void)dealloc
{
    [self.calendar removeObserver:self forKeyPath:@"scope" context:__KVOContext];
    NSLog(@"%s",__FUNCTION__);
}


#pragma mark - widgetConfiguration
//- (void) widgetConfiguration {
//    NSUserDefaults * sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:WIDGET_NAME];
//    
//    [_eventManager sortTimeOrder:[NSDate date] complete:^(NSMutableArray *eventArray) {
//        NSMutableArray * eventsForWidget = [[NSMutableArray alloc] initWithArray:eventArray];
//        
//        EKEvent * event;
//        NSString * dateStr;
//        NSString * eventTitle;
//        
//        NSMutableArray * widgetEvent = [NSMutableArray new];
//        
//        if (eventsForWidget.count != 0) {
//            
//            for (int i = 0; i < eventsForWidget.count; i++) {
//                event = [eventsForWidget objectAtIndex:i];
//                
//                NSDateFormatter * today = [NSDateFormatter new];
//                today.dateFormat = @"HH:mm";
//                
//                dateStr = [today stringFromDate:event.startDate];
//                eventTitle = event.title;
//                
//                NSMutableDictionary * dict = [NSMutableDictionary new];
//                dict = [@{@"today date":dateStr, @"event title":eventTitle} mutableCopy];
//                
//                [widgetEvent addObject:dict];
//                //the first object contains the latest date and title...
//            }
//        }
//        
//        [sharedDefaults setObject:widgetEvent forKey:@"eventsArray"];
//        [sharedDefaults synchronize];
//    }];
//}

#pragma mark - FSCALENDAR
/// MARK: FSCalendar Delegates
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    chosenDate = date;
    
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    
    [_eventManager sortTimeOrder:date complete:^(NSMutableArray *eventArray) {
        allEventsArray = [[NSMutableArray alloc] initWithArray:eventArray];
        [_tableView reloadData];
    }];
    
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    _calendarHeight.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}

-(UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date {
    
    [gregorian component:NSCalendarUnitDay fromDate:date];
    
    NSCalendar * nsCalendar = [NSCalendar currentCalendar];
    
    NSDate * amDate = [nsCalendar dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
    
    NSDate * pmDate = [nsCalendar dateBySettingHour:23 minute:59 second:59 ofDate:date options:0];
    
    NSInteger eventNumber = -1;
    
    @try {
        NSPredicate *predicate = [_eventManager predicateForEventsWithStartDate:amDate
                                                                        endDate:pmDate
                                                                      calendars:@[eventStore.defaultCalendarForNewEvents]];
        NSArray * events = [_eventManager eventsMatchingPredicate:predicate];
        eventNumber = events.count;
    } @catch (NSException *exception) {
        
    }

    if (eventNumber > 0){
        return [UIImage imageNamed:@"eventDot"];
    }
    else{
        return nil;
    }

}

/// MARK: Calendar SETUP
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


- (void) fsCalendarSetUp {
    [_calendar.appearance setAdjustsFontSizeToFitContentSize:false];
    [_calendar.appearance setHeaderTitleFont:[UIFont systemFontOfSize:28]];
    [_calendar.appearance setTitleFont:[UIFont systemFontOfSize:25]];
    [_calendar.appearance setSubtitleFont:[UIFont systemFontOfSize:12]];
    [_calendar.appearance setWeekdayFont:[UIFont systemFontOfSize:15]];
    [_calendar setScope: FSCalendarScopeMonth];
    
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
    [cell.startTimeLabel setAdjustsFontSizeToFitWidth:true];
    [cell.eventTitle setAdjustsFontSizeToFitWidth:true];
    [cell.endtimeLabel setAdjustsFontSizeToFitWidth:true];
    [cell.eventTitle setNumberOfLines:0];
    [cell.startTimeLabel setNumberOfLines:0];
    [cell.endtimeLabel setNumberOfLines:0];
    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"eventDetail" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        FSCalendarScope selectedScope = indexPath.row == 0 ? FSCalendarScopeMonth : FSCalendarScopeWeek;
        [self.calendar setScope:selectedScope animated:YES];
    }
}


#pragma mark - EKEventEditViewDelegate
// Overriding EKEventEditViewDelegate method to update event store according to user actions.
-(void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    
    ViewController * __weak weakSelf = self;
    if (action != EKEventEditViewActionCanceled) {
        NSString * startDate = [dateFormatter stringFromDate: controller.event.startDate];
        NSString * endDate = [dateFormatter stringFromDate: controller.event.endDate];
        
        newEvent = @{@"title" : controller.event.title,
                     EVENT_START_KEY: startDate,
                     EVENT_END_KEY : endDate,
                     @"detail" : controller.event.description,
                     @"location" : controller.event.location,
                     };
        [_eventManager checkNewEvent:newEvent complete:^(NSMutableArray *eventArray) {
            if ([eventArray[0] isEqual:@(0)]){
                NSError * error;
                [controller.eventStore removeEvent:controller.event span:EKSpanThisEvent error:&error];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"時間上有沖突喔，無法儲存。" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"知道了" style:0 handler:nil];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:true completion:nil];
                });
                if (error){
                    NSLog(@"ERROR : %@", error.description);
                }
            } else {
                [Widget widgetConfigurationWithTemperature:nil conditions:nil complete:^(NSError *error, id result) {
                   
                }];
            }
        }];
    }
    
    //Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:^{

        dispatch_async(dispatch_get_main_queue(), ^{
                 [_eventManager sortTimeOrder:[NSDate date] complete:^(NSMutableArray *eventArray) {
                     [Widget widgetConfigurationWithTemperature:nil conditions:nil complete:^(NSError *error, id result) {
                         
                     }];
                 }];
            
                [weakSelf.tableView reloadData]; //Update the UI with the above events
            });
    }]; // end of self dismiss
}

//Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar
-(EKCalendar *) eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
    return _eventManager.defaultCalendar;
}

#pragma mark - BUTTONS
/// MARK: addEventBtn
- (IBAction)addEventBtnPressed:(id)sender {
    
    //    Create an instance of EKEventEditViewController
    EKEventEditViewController * addController = [EKEventEditViewController new];
    
    //Set addController's event store to the current event store
    addController.eventStore = _eventManager;
    addController.editViewDelegate = self;
    [addController.event setStartDate:chosenDate];
    
    addNewevent = [EKEvent eventWithEventStore:addController.eventStore];
    
    //    [self performSegueWithIdentifier:@"ChangeViewController" sender:sender];
    [self presentViewController:addController animated:YES completion:nil];
}

/// MARK: SEGUE
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"eventDetail"]) {
        // Configure the destination event view controlle
        EKEventViewController * editEventViewController = (EKEventViewController *) segue.destinationViewController;
        // Fetch the index path associated with the selected event
        NSIndexPath * indexPath = _tableView.indexPathForSelectedRow;
        // Set the view controller to display the selected event
        if (allEventsArray.count != 0){
            editEventViewController.event = allEventsArray[indexPath.row];
        }
        // Allow event editing
        editEventViewController.allowsEditing = true;
    }
}


#pragma mark - ===Request Access to Event===
-(void) requestAccessToEventType {
    [_eventManager requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"%@", error);
            return;
        }
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"無法存取" message:@"「哈啦哈啦趣」無法存取您的行事曆。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * ok = [UIAlertAction actionWithTitle:@"瞭解" style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction * redirect = [UIAlertAction actionWithTitle:@"設定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [alert addAction:ok];
                [alert addAction:redirect];
                
                [self presentViewController:alert animated:YES completion:nil];
            });
            
            return;
        }
        _eventManager.eventsAccessGranted = granted;
    }];
}

#pragma mark - ===UpdateAuthorizationStatusToAccessEventStore===
- (void) updateAuthorizationStatusToAccessEventStore {
    
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusDenied:
            break;
            
        case EKAuthorizationStatusRestricted: {
            isAccessToEventStoreGranted = false;
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"無法存取" message:@"「哈啦哈啦趣」無法存取您的行事曆。" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"瞭解" style:UIAlertActionStyleDefault handler:nil];
            UIAlertAction * redirect = [UIAlertAction actionWithTitle:@"設定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [alert addAction:ok];
            [alert addAction:redirect];
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
                    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"瞭解" style:UIAlertActionStyleDefault handler:nil];
                    UIAlertAction * redirect = [UIAlertAction actionWithTitle:@"設定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alert addAction:ok];
                    [alert addAction:redirect];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
            break;
        }
        default:
            break;
    }
}



@end
