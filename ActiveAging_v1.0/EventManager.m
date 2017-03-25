//
//  EventManager.m
//  EventManagerTest3
//
//  Created by Ga Wai Lau on 1/18/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import "EventManager.h"
#import "EventListTableViewController.h"
#import "Definitions.h"

static EventManager * _store = nil;

@interface EventManager () {
    EventListTableViewController * eventListVC;
    NSDateFormatter * timeFormatter;
    NSArray * comparedWithNewEvent;
    NSArray *events;
    NSString * amString;
    NSString * pmString;
    NSArray * calendarArray;
    EKEvent * addEvent;
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
    

    dispatch_async(dispatch_get_main_queue(), ^{
         int counter = 0;
        NSMutableArray * allEvents  = [NSMutableArray new];
        
            for (EKEvent * e in events) {
                [allEvents addObject:e];
                
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
        done(allEvents);
    });

} //end of NSMutableArray

// ================ Data from EventsListTableView ================= //

/// MARK: REMOVE EVENTS
- (void) eventToBeRemoved: (NSDictionary *) event complete:(Donehandler) done {
    NSDictionary * dict = event;
    NSString * startDateTimeStr = dict[EVENT_START_KEY];
    NSString * endDateTimeStr = dict[EVENT_END_KEY];

    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate * startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    
    if (startDateTime == nil){
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    }
    NSDate * endDateTime = [dateFormatter dateFromString:endDateTimeStr];
    
    [self comparedWithStoredEvents:startDateTime newEventEndDateTime:endDateTime complete:^(NSMutableArray *eventArray) {
        if ([eventArray[0] isEqual:@(1)]){
            EKEvent * targetEvent = [self eventWithIdentifier:eventArray.lastObject];
            [self removeEvent:targetEvent span:EKSpanThisEvent error:nil];
            done([@[@"true"] mutableCopy]);
        } else{
            NSLog(@"NOTHING FOUND");
            done([@[@"false"] mutableCopy]);
        }
    }];
}

/// MARK: ADD NEW EVENTS
-(void) newEventToBeAdded:(NSDictionary *)newEvent complete:(Donehandler)done {
    NSString * startDateTimeStr = newEvent[EVENT_START_KEY];
    NSString * titleStr = newEvent[EVENT_TITLE_KEY];
    NSString * endDateTimeStr = newEvent[EVENT_END_KEY];
    NSString * detailStr = newEvent[EVENT_DESCRIPTION_KEY];
    NSString * locationStr = newEvent[EVENT_ADDRESS_KEY];
    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate * startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    if (startDateTime == nil){
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    }
    
    NSDate * endDateTime = [dateFormatter dateFromString:endDateTimeStr];

    addEvent = [EKEvent eventWithEventStore:_store];
    [addEvent setCalendar:[_store defaultCalendarForNewEvents]];
    _defaultCalendar = _store.defaultCalendarForNewEvents;
    calendarArray = @[self.defaultCalendar];
    
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
    } else {
        NSLog(@"Event External Identifier not saved:%@", error);
    }
}

-(void) checkNewEvent:(NSDictionary *)newEvent complete:(Donehandler)done {
    NSString * startDateTimeStr = newEvent[EVENT_START_KEY];
    NSString * endDateTimeStr = newEvent[EVENT_END_KEY];

    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate * startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    if (startDateTime == nil){
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        startDateTime = [dateFormatter dateFromString:startDateTimeStr];
    }
    NSDate * endDateTime = [dateFormatter dateFromString:endDateTimeStr];
    
    [self comparedWithStoredEvents:startDateTime newEventEndDateTime:endDateTime complete:done];
}

/// MARK: COMPARE STORED EVENTS
-(void) comparedWithStoredEvents:(NSDate *)newEventStartDateTime newEventEndDateTime:(NSDate *)newEventEndDateTime complete:(Donehandler)done {
    
    NSPredicate * predicate = [_store predicateForEventsWithStartDate:newEventStartDateTime
                                                              endDate:newEventEndDateTime
                                                            calendars:calendarArray];
    comparedWithNewEvent = [_store eventsMatchingPredicate:predicate];
    
    
    
    if (!comparedWithNewEvent){
        done([@[@(true)] mutableCopy]);
        return;
    }
    
    EKEvent * event;
    
    NSInteger counter = 0;
    addEvent.startDate = newEventStartDateTime;
    for (EKEvent * e in comparedWithNewEvent) {
        if (newEventStartDateTime == e.startDate) {
            // if event at the same time was found
            counter++;
            if (counter>1){
                done([@[@(false), e.eventIdentifier] mutableCopy]);
                return;
            }
            event = e;
        }
    }
    
    done([@[@(true),event.eventIdentifier ] mutableCopy]);
}

- (void)fetchAllEvents:(NSDate *)startingFromDate complete:(Donehandler)done {
    
    if (_eventsAccessGranted){
        
        // Let's get the default calendar associated with our event store
        _defaultCalendar = _store.defaultCalendarForNewEvents;
        
        //Only search the default calendar for our events
        if (self.defaultCalendar){
            calendarArray = @[self.defaultCalendar];
        }
        
        NSDate * startFrom = [startingFromDate dateByAddingTimeInterval:-604800*10];
        //This is 10 weeks in seconds
        
        NSPredicate * fetchAllPredicate = [_store predicateForEventsWithStartDate:startFrom endDate:[NSDate distantFuture] calendars:calendarArray];
        
        events = [_store eventsMatchingPredicate:fetchAllPredicate];
        
            int counter = 0;
            NSMutableArray * allEvents  = [NSMutableArray new];
            
            for (EKEvent * e in events) {
                [allEvents addObject:e];
                
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
            done(allEvents);
    }
} //end of NSMutableArray

@end
