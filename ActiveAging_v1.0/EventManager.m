//
//  EventManager.m
//  EventManagerTest3
//
//  Created by Ga Wai Lau on 1/18/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import "EventManager.h"
#import "EventListTableViewController.h"

static EventManager * _store = nil;

@interface EventManager () {
    NSArray *events;
    NSDateFormatter * timeFormatter;
    NSString * amString;
    NSString * pmString;
    NSArray * calendarArray;
    EventListTableViewController * eventListVC;
    EKEvent * addEvent;
    NSArray * comparedWithNewEvent;
}

@end

@implementation EventManager

/* ============= Create Singleton =============== */
+(instancetype) shareInstance{
    if (_store == nil){
        
        _store = [EventManager new];
    }
    return _store;
}

// ================ Data from Calendar ================= //
#pragma mark - sortTimeOrder
-(void) sortTimeOrder: (NSDate *) dateSelected complete:(Donehandler)done{
    
    if (_eventsAccessGranted){
    
    
        NSCalendar * calendar = [NSCalendar currentCalendar];
        
        NSDate * amDate = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:dateSelected options:0];
        
        NSDate * pmDate = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:dateSelected options:0];
        
        [self amTime:amDate pmTime:pmDate complete:done];
        
        // Let's get the default calendar associated with our event store
        _defaultCalendar = _store.defaultCalendarForNewEvents;
        
        //Only search the default calendar for our events
        if (self.defaultCalendar){
            calendarArray = @[self.defaultCalendar];
        }
    }
}

-(void) amTime: (NSDate *)amTime pmTime: (NSDate *)pmTime complete:(Donehandler)done {

    NSPredicate *predicate = [_store predicateForEventsWithStartDate:amTime
                                                            endDate:pmTime
                                                            calendars:calendarArray];
        
    events = [_store eventsMatchingPredicate:predicate];
    
    //Sort Data in order
    timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"HH:mm";
    
    amString = [timeFormatter stringFromDate:amTime];
    pmString = [timeFormatter stringFromDate:pmTime];
    
//    NSLog(@"am: %@\npm: %@\n", amString, pmString);

    _eventsObtained = [NSMutableDictionary new];

    dispatch_async(dispatch_get_main_queue(), ^{
         int counter = 0;
        NSMutableArray * test  = [NSMutableArray new];
            for (EKEvent * e in events) {
                [test addObject:e];
                
                NSError * error = nil;

                NSString * itemIdentifier = e.calendarItemIdentifier;

                BOOL result = [_store saveEvent:e span:EKSpanThisEvent error:&error];
    
                if (result) {
                    [[NSUserDefaults standardUserDefaults] setObject:itemIdentifier     forKey:@"itemIdentifier"];
                } else {
                    NSLog(@"Event Identifier not saved:%@", error);
                }
                counter++;
            } //end of for (EKEvent * e in events)
        done(test);
    });

} //end of NSMutableArray

// ================ Data from EventsListTableView ================= //
-(void) comparedWithStoredEvents:(NSDate *)newEventStartDateTime newEventEndDateTime:(NSDate *)newEventEndDateTime complete:(Donehandler)done {
    
    
    NSPredicate * predicate = [_store predicateForEventsWithStartDate:newEventStartDateTime
                                                              endDate:newEventEndDateTime
                                                            calendars:calendarArray];
    comparedWithNewEvent = [_store eventsMatchingPredicate:predicate];
    
    
    
    if (!comparedWithNewEvent){
        done([@[@(true)] mutableCopy]);
        return;
    }
    
    addEvent.startDate = newEventStartDateTime;
    
    for (EKEvent * e in comparedWithNewEvent) {
         if (addEvent.startDate != e.startDate) {
             done([@[@(true)] mutableCopy]);
         } else {
             done([@[@(false), e.eventIdentifier] mutableCopy]);
//             [eventListVC isNewEventAdded:false];
         }
    }
}

- (void) eventToBeRemoved: (NSDictionary *) event complete:(Donehandler) done {
    NSString * startDateTimeStr = event[@"startDateTime"];
//    NSString * titleStr = event[@"title"];
    NSString * endDateTimeStr = event[@"endDateTime"];
//    NSString * detailStr = event[@"detail"];
//    NSString * locationStr = event[@"location"];
    
    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate * startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    if (startDateTime == nil){
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    }
    NSDate * endDateTime = [dateFormatter dateFromString:endDateTimeStr];
    
//    EKEvent * targetEvent = [EKEvent eventWithEventStore:_store];
    
    
    [self comparedWithStoredEvents:startDateTime newEventEndDateTime:endDateTime complete:^(NSMutableArray *eventArray) {
        if ([eventArray[0] isEqual:@(0)]){
            EKEvent * targetEvent = [self eventWithIdentifier:eventArray.lastObject];
            [self removeEvent:targetEvent span:EKSpanThisEvent error:nil];
            done([@[@"true"] mutableCopy]);
        } else{
            NSLog(@"NOTHING FOUND");
            done([@[@"false"] mutableCopy]);
        }
    }];
}

-(void) newEventToBeAdded:(NSDictionary *)newEvent complete:(Donehandler)done {
    NSString * startDateTimeStr = newEvent[@"startDateTime"];
    NSString * titleStr = newEvent[@"title"];
    NSString * endDateTimeStr = newEvent[@"endDateTime"];
    NSString * detailStr = newEvent[@"detail"];
    NSString * locationStr = newEvent[@"location"];
    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate * startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    if (startDateTime == nil){
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    }
    NSDate * endDateTime = [dateFormatter dateFromString:endDateTimeStr];
//    endDateTime = [NSDate dateWithTimeIntervalSinceReferenceDate:162000];
    addEvent = [EKEvent eventWithEventStore:_store];
    [addEvent setCalendar:[_store defaultCalendarForNewEvents]];
    _defaultCalendar = _store.defaultCalendarForNewEvents;
    calendarArray = @[self.defaultCalendar];

    
    [self comparedWithStoredEvents:startDateTime newEventEndDateTime:endDateTime complete:done];
    
    //Create new event if event does not exist
    addEvent.title = titleStr;
    addEvent.startDate = startDateTime;
    addEvent.endDate = endDateTime;
    addEvent.location = locationStr;
    addEvent.notes = detailStr;
    
    NSError * error = nil;
    
    NSString * itemIdentifier = addEvent.calendarItemIdentifier;
    
    BOOL result = [_store saveEvent:addEvent span:EKSpanThisEvent error:&error];
    
    if (result) {
        [[NSUserDefaults standardUserDefaults] setObject:itemIdentifier     forKey:@"itemIdentifier"];
//        [eventListVC isNewEventAdded:true];
    } else {
        NSLog(@"Event External Identifier not saved:%@", error);
    }
}

-(void) checkNewEvetn:(NSDictionary *)newEvent complete:(Donehandler)done {
    NSString * startDateTimeStr = newEvent[@"startDateTime"];
    NSString * endDateTimeStr = newEvent[@"endDateTime"];

    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate * startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    if (startDateTime == nil){
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    }
    NSDate * endDateTime = [dateFormatter dateFromString:endDateTimeStr];
    //    endDateTime = [NSDate dateWithTimeIntervalSinceReferenceDate:162000];
    addEvent = [EKEvent eventWithEventStore:_store];
    [addEvent setCalendar:[_store defaultCalendarForNewEvents]];
    _defaultCalendar = _store.defaultCalendarForNewEvents;
    calendarArray = @[self.defaultCalendar];
    
    
    [self comparedWithStoredEvents:startDateTime newEventEndDateTime:endDateTime complete:done];
}
@end
