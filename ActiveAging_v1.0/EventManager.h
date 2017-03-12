//
//  EventManager.h
//  EventManagerTest3
//
//  Created by Ga Wai Lau on 1/18/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

typedef void (^Donehandler)(NSMutableArray * eventArray);

@interface EventManager : EKEventStore

@property (nonatomic) BOOL eventsAccessGranted;
@property NSMutableDictionary * eventsObtained;
@property NSMutableArray * eventsArray;
@property (nonatomic,strong) EKCalendar * defaultCalendar;

+ (instancetype) shareInstance;

-(void) amTime: (NSDate *)amTime pmTime: (NSDate *)pmTime complete: (Donehandler) done;

-(void) sortTimeOrder: (NSDate *) dateSelected complete:(Donehandler) done;

-(void) comparedWithStoredEvents: (NSDate *)newEventStartDateTime newEventEndDateTime:(NSDate *) newEventEndDateTime complete:(Donehandler) done;

-(void) newEventToBeAdded: (NSDictionary *) newEvent complete: (Donehandler) done;

- (void) eventToBeRemoved: (NSDictionary *) event complete:(Donehandler) done;

-(void) checkNewEvent:(NSDictionary *)newEvent complete:(Donehandler)done;

- (void) fetchAllEvents: (NSDate *) startingFromDate complete:(Donehandler) done;

@end
