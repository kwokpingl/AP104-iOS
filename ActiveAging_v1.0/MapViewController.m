//
//  MapViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/24/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "MapViewController.h"
#import "ServerManager.h"
#import "DataManager.h"
#import "LocationManager.h"
#import "UserInfo.h"
#import "MapTableViewCell.h"
#import "MemberDetailViewController.h"

#import "MemberAnnotationView.h"
#import "InfrastructureAnnotationView.h"
#import "MemberPointAnnotation.h"
#import "CustomPointAnnotation.h"

#import <MapKit/MapKit.h>
#import "MKMapView+Autoadjustment.h"



typedef enum : NSUInteger {
    noSelection,
    personalGroups,
    otherGroups,
    activities,
} GeneralGroups;

typedef void (^MKETAHandler)(MKETAResponse * __nullable response, NSError * __nullable error);

@interface MapViewController () <MKMapViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, LocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionStyleSwitcher;
@property (weak, nonatomic) IBOutlet UISwitch *shareLocationSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerview;
@property (weak, nonatomic) IBOutlet UIView *memberDetailView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (weak, nonatomic) IBOutlet UIView *groupView;

@property (strong, nonatomic) NSMutableDictionary * friendListDict;
@property (strong, nonatomic) NSMutableArray * targetFriendList; // contains details of a Specific friend
@property (strong, nonatomic) NSMutableArray * eventsLocations;
@property (strong, nonatomic) NSMutableArray * targetList; // contains detail of a Certain group / Certain event
@property (strong, nonatomic) NSMutableArray * groupList; // contains details of the Groups
@property (strong, nonatomic) NSMutableArray * eventList; // contains detail of Joined Events

@property (strong, nonatomic) NSArray * generalGroupList; // contains the Title of Groups (ie Personal Groups, Other Groups, Activities ...)
@property (strong, nonatomic) NSArray <MKRouteStep *> * routeStep;
@property (strong, nonatomic) UIViewController * currentVC;
@property (strong, nonatomic) MKPolyline * routeOverlay;
@property (strong, nonatomic) MKRoute * currentRoute;

@property (assign) CLLocationCoordinate2D targetLocation;
@property (assign) NSInteger chosenGroup; // use to determine wheather Group/Event was chosen
@end

@implementation MapViewController{
    
    MKDirectionsTransportType transportationType;
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    CLLocation * specificLocation;
    MKPolyline * polyLine;
    BOOL shareLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"TestViewController Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef) self));

    // SETUP SINGLETONs
    _userInfo = [UserInfo shareInstance];
//    [LocationManager shareInstance] = [LocationManager shareInstance];
    
    if ([LocationManager shareInstance].accessGranted){
        [[LocationManager shareInstance] startMonitoringSignificatnLocationChanges];
    }
    
    
    // Check if user wish to ShareLocation
    shareLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:@"shareLocation"] boolValue];
    
    // SETUP VIEWS
    [_shareLocationSwitch setOn:shareLocation];
    [_mapview setShowsUserLocation:true];
    [_memberDetailView setHidden:true];
    [_pickerview setDataSource:self];
    [_tableView setDataSource:self];
    [[LocationManager shareInstance] setDelegate:self];
    [_pickerview setDelegate:self];
    [_tableView setDelegate:self];
    [_mapview setDelegate:self];
    [_groupView setHidden:true];
    
    
    [self setupInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [[LocationManager shareInstance] startUpdatingLocation];
}

-(void)viewDidAppear:(BOOL)animated{
    [_mapview locatePointA:[LocationManager shareInstance].location.coordinate];
    [_pickerview selectRow:0 inComponent:0 animated:true];
    [self pickerView:_pickerview didSelectRow:0 inComponent:0];
}


#pragma mark - LOCATION MANAGER
- (void) locationControllerDidUpdateLocation: (CLLocation *) location{
    
    // Update the database
    [DataManager updateContactDatabase:^(BOOL done) {
        
    }];
    
    if ([_currentVC isKindOfClass:[MemberDetailViewController class]] && ![_memberDetailView isHidden]){
        NSInteger userID = ((MemberDetailViewController *) _currentVC).userID;
        NSArray * tempArray = [DataManager fetchUserInfoFromTableWithUserID:userID];
        CLLocationDegrees lon = [tempArray.lastObject[USER_CUR_LON_KEY] doubleValue];
        CLLocationDegrees lat = [tempArray.lastObject[USER_CUR_LAT_KEY] doubleValue];
        _targetLocation = CLLocationCoordinate2DMake(lat, lon);
    }
    
    if (CLLocationCoordinate2DIsValid(_targetLocation)){
        [self showDirection:_targetLocation];
    }
    
    if (![_groupView isHidden]){
        [_tableView reloadData];
    }
}

#pragma mark - MAP
/// MARK: ANNOTATION
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // return nil if annotation @ userLocation
    if (annotation == mapView.userLocation){
        return nil;
    }
    
    // if annotation is MemberPointAnnotation
    if ([annotation isKindOfClass:[MemberPointAnnotation class]]){
        float distance = ((MemberAnnotationView *) annotation).distance;
        MemberAnnotationView * pin = [[MemberAnnotationView alloc] initWithAnnotation:annotation distance:distance];
        return pin;
    }
    
    // if annotation is CustomPointAnnotation
    if ([annotation isKindOfClass:[CustomPointAnnotation class]]){
        InfrastructureAnnotationView * annotationView = [[InfrastructureAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:((CustomPointAnnotation *)annotation).type];
        return annotationView;
    }
    
    return nil;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer * line = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    [line setStrokeColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5]];
    [line setLineWidth:5.0];
    return line;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [_mapview setRegionBetweenA:[view.annotation coordinate] andB:[LocationManager shareInstance].location.coordinate];
    _targetLocation = view.annotation.coordinate;
    [self showDirection:_targetLocation];
    
    MemberDetailViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MemberDetailViewController"];
    MemberPointAnnotation * annotation;
    if ([view.annotation isKindOfClass:[MemberPointAnnotation class]]){
        annotation = (MemberPointAnnotation *) view.annotation;
        
        NSInteger i = annotation.tag;
        
        if (_chosenGroup != activities){
            vc.userID = [_targetFriendList[i][USER_ID_KEY] integerValue];
            vc.phoneNumber = _targetFriendList[i][USER_PHONENUMBER_KEY];
            vc.name = _targetFriendList[i][USER_NAME_KEY];
            vc.eventImageName = @"0";
        }
        else if (_chosenGroup == activities){
            vc.userID = 0;
            vc.phoneNumber = _targetList[i][EVENT_ORGN_PHONE_KEY];
            vc.eventImageName = _targetList[i][EVENT_PIC_KEY];
            vc.name = _targetList[i][EVENT_TITLE_KEY];
        }
        
    }
    /// MARK: INFRASTRUCTURE
    if ([view.annotation isKindOfClass:[CustomPointAnnotation class]]){
        vc.userID = -1;
        NSString * phoneNumber = ((CustomPointAnnotation *) view.annotation).phone;
        
        if (phoneNumber != nil){
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+886 " withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phoneNumber = [@"0" stringByAppendingString:phoneNumber];
            phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
            [vc setPhoneNumber: phoneNumber];
        }
        
        [vc setCustomImage: ((CustomPointAnnotation *) view.annotation).image];
        [vc setName: ((CustomPointAnnotation *) view.annotation).title];
    }
    [self setSubView:vc];
    
}

#pragma mark - PICKER
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return _generalGroupList.count;
    }
    return _targetList.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row
           forComponent:(NSInteger)component
{
    if (component == 0) {return _generalGroupList[row];}
    if (_chosenGroup != activities){ return _targetList[row][GROUP_NAME_KEY];}
    return _targetList[row][EVENT_TITLE_KEY];
}

-(void)pickerView:(UIPickerView *)pickerView
     didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component{
    
    if (component == 0)
    {
        [_mapview removeAnnotations:_mapview.annotations];
        // User pick the GENERAL group
        _targetList = [NSMutableArray new];
        
        switch (row) {
                // Personal Groups Chosen
            case personalGroups:
                [_targetList addObject:@{GROUP_ID_KEY:@(0), GROUP_NAME_KEY: @"請選組", USER_ROLE_KEY:@(0)}];
                [_targetList addObjectsFromArray:_groupList[0]];
                _chosenGroup = personalGroups;
                break;
                
                // Other Groups Chosen
            case otherGroups:
                [_targetList addObject:@{GROUP_ID_KEY:@(0), GROUP_NAME_KEY: @"請選組", USER_ROLE_KEY:@(0)}];
                [_targetList addObjectsFromArray:_groupList[1]];
                _chosenGroup = otherGroups;
                break;
                
                // Activities Chosen
            case activities:
            {
                [_targetList addObject:@{EVENT_ID_KEY:@(0), EVENT_TITLE_KEY: @"請選活動"}];
                [_targetList addObjectsFromArray:_eventList[0]];
                _chosenGroup = activities;
                
                // Show all joined activities' locations
                [_mapview removeAnnotations:_mapview.annotations];
                NSMutableArray * coordinates = [NSMutableArray new];
                for (int i = 1; i < _targetList.count; i++)
                {
                    [coordinates addObject:@[_targetList[i][EVENT_LAT_KEY],
                                            _targetList[i][EVENT_LON_KEY]]];
                }
                
                [coordinates addObject:@[@([LocationManager shareInstance].location.coordinate.latitude),
                                        @([LocationManager shareInstance].location.coordinate.longitude)]];
                
                [_mapview recenterMap:coordinates];
                [self showAnnotation];
            }
                break;
                
            default:
                [self policsStationSearch:[LocationManager shareInstance].location.coordinate];
                [_mapview locatePointA:[LocationManager shareInstance].location.coordinate];
                [self hospitalSearch:[LocationManager shareInstance].location.coordinate];
                _targetList = [NSMutableArray new];
                
                break;
        }
        [_pickerview reloadComponent:1];
        [_pickerview selectRow:0 inComponent:1 animated:true];
    }
    else{
        // if USER_GROUPS were chosen
        if (_chosenGroup != activities)
        {
            _targetFriendList = [NSMutableArray new];
            
            // if the targetList has more than 1 list
            if (_targetList.count > 1 && [_targetList[0] objectForKey:GROUP_ID_KEY] != nil)
            {
                NSInteger groupID = [_targetList[row][GROUP_ID_KEY] integerValue];
                
                if (groupID == 0)
                {
                    [_groupView setHidden:true];
                    [_directionStyleSwitcher setHidden:false];
                }
                else
                {
                    [_targetFriendList addObject:@{USER_NAME_KEY:@"全部"}];
                    [_targetFriendList addObjectsFromArray:_friendListDict[@(groupID)]];
                    [_directionStyleSwitcher setHidden:true];
                    [_groupView setHidden:false];
                    [_tableView reloadData];
                }
            }
        }
        // If ACTIVITIES were chosen
        else {
            if (row != 0){
                CLLocationDegrees lat = [_targetList[row][EVENT_LAT_KEY] doubleValue];
                CLLocationDegrees lon = [_targetList[row][EVENT_LON_KEY] doubleValue];
                
                CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
                
                if (CLLocationCoordinate2DIsValid(location)){
                    [self showDirection:location];
                }
                
                MemberDetailViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MemberDetailViewController"];
                [vc setPhoneNumber: _targetList[row][EVENT_ORGN_PHONE_KEY]];
                [vc setEventImageName: _targetList[row][EVENT_PIC_KEY] ];
                [vc setUserID:0];
                
                [self setSubView:vc];
            }
            else {
                NSMutableArray * coordinates = [NSMutableArray new];
                for (int i = 1; i < _targetList.count; i++)
                {
                    [coordinates addObject:@[_targetList[i][EVENT_LAT_KEY], _targetList[i][EVENT_LON_KEY]]];
                }
                
                [coordinates addObject:@[@([LocationManager shareInstance].location.coordinate.latitude),
                                        @([LocationManager shareInstance].location.coordinate.longitude)]];
                
                [_mapview recenterMap:coordinates];
            }
            
        }
    }
    
}




#pragma mark - TABLEVIEW
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _targetFriendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MapTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.titleLabel setText: _targetFriendList[indexPath.row][USER_NAME_KEY] ];
    [cell.titleLabel setNumberOfLines:0];
    if (indexPath.row == 0){
        [cell.subtitleLabel setText: @""];
    }
    else{
        if (![_targetFriendList[indexPath.row][USER_CUR_LON_KEY] isEqualToString:@"<null>"]
            && ![_targetFriendList[indexPath.row][USER_CUR_LAT_KEY] isEqualToString:@"<null>"]){
            
            CLLocationDegrees lon = [_targetFriendList[indexPath.row][USER_CUR_LON_KEY] doubleValue];
            CLLocationDegrees lat = [_targetFriendList[indexPath.row][USER_CUR_LAT_KEY] doubleValue];
            
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
            
            [self getETA:location withDonehandler:^(MKETAResponse * _Nullable response, NSError * _Nullable error) {
                NSString * expectedTime = @"";
                if (error){
                    expectedTime = @"未知";
                }
                else{
                    
                    NSTimeInterval minutes = response.expectedTravelTime/60.0;
                    
                    if (minutes>= 60.0){
                        
                        expectedTime = [NSString stringWithFormat:@"距離 %d 小時 %d分鐘",
                                        (int)minutes/60, (int)minutes%60];
                    }
                    
                    else if (minutes < 60) {
                        expectedTime = [NSString stringWithFormat:@"距離 %d 分鐘", (int) minutes];
                    }
                    else {
                        expectedTime = @"未知";
                    }
                    [cell.subtitleLabel setNumberOfLines:0];
                    [cell.subtitleLabel setText: expectedTime];
                }
            }];
        }
        else {
            [cell.subtitleLabel setText:@"未知" ];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [_groupView setHidden:true];
    CLLocationDegrees lon;
    CLLocationDegrees lat;
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // show all people, change the span and center below
    
    if (indexPath.row == 0)
    {
        // show most people in the map together
        NSMutableArray * coordinates = [NSMutableArray new];
        for (int i = 1; i < _targetFriendList.count; i++)
        {
            [coordinates addObject:@[_targetFriendList[i][USER_CUR_LAT_KEY], _targetFriendList[i][USER_CUR_LON_KEY]]];
        }
        
        [coordinates addObject:@[@([LocationManager shareInstance].location.coordinate.latitude), @([LocationManager shareInstance].location.coordinate.longitude)]];
        
        [_mapview recenterMap:coordinates];
    }
    else
    {
        [_mapview removeAnnotations:_mapview.annotations];
        if (![cell.detailTextLabel.text isEqualToString:@"UNKNOWN"]){
            lon = [_targetFriendList[indexPath.row][USER_CUR_LON_KEY] doubleValue];
            lat = [_targetFriendList[indexPath.row][USER_CUR_LAT_KEY] doubleValue];
            _targetLocation = CLLocationCoordinate2DMake(lat, lon);
            [_mapview setRegionBetweenA:_targetLocation andB:[LocationManager shareInstance].location.coordinate];
            
            [self showDirection:_targetLocation];
            MemberDetailViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MemberDetailViewController"];
            vc.phoneNumber = _targetFriendList[indexPath.row][USER_PHONENUMBER_KEY];
            vc.userID = [_targetFriendList[indexPath.row][USER_ID_KEY] integerValue];
            vc.eventImageName = @"0";
            vc.name = _targetFriendList[indexPath.row][USER_NAME_KEY];
            [self setSubView:vc];
        }
        [_mapview removeOverlay:_routeOverlay];
    }
    
    [self showAnnotation];
    [_directionStyleSwitcher setHidden:false];
}

/// MARK: TABLE_VIEW_PROPERTIES
-(CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{ return 40.0; }

-(CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section{ return 5.0; }

-(CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section{ return 5.0; }



#pragma mark - BUTTONS
- (IBAction)returnButtonPresssed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)shouldShareLocationSwitch:(id)sender {
    shareLocation = !shareLocation;
    [_userInfo changeShareLocation];
}

- (IBAction)travelTypeSwitching:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0){
        transportationType = MKDirectionsTransportTypeWalking;
    }
    else{
        transportationType = MKDirectionsTransportTypeAutomobile;
    }
    if (CLLocationCoordinate2DIsValid(_targetLocation)){
        [self showDirection:_targetLocation];
    }
}

#pragma mark - PRIVATE METHODS
/// MARK: MAP_RELATED
- (void) showAnnotation {
    MemberPointAnnotation * annotation;
    CLLocationCoordinate2D location;
    
    if (_chosenGroup != activities && _targetFriendList.count > 0){
        
        for (int i = 1; i < _targetFriendList.count; i++){
            
            if (_targetFriendList[i][USER_CUR_LAT_KEY] != [NSNull null] && _targetFriendList[i][USER_CUR_LON_KEY] != [NSNull null]){
            
                CLLocationDegrees lat = [_targetFriendList[i][USER_CUR_LAT_KEY] doubleValue];
                CLLocationDegrees lon = [_targetFriendList[i][USER_CUR_LON_KEY] doubleValue];
                location = CLLocationCoordinate2DMake(lat, lon);
                annotation = [MemberPointAnnotation new];
                
                [annotation setDistance: [[LocationManager shareInstance] distanceFromLocationUsingLongitude:lon Latitude:lat]];
                [annotation setTitle:_targetFriendList[i][USER_NAME_KEY]];
                [annotation setCoordinate:location];
                [annotation setTag:i];
                
                
                [_mapview addAnnotation:annotation];
            }
        }
        
    }
    else if (_chosenGroup == activities && _targetList.count>1){
        for (int i = 1; i < _targetList.count; i++){
            CLLocationDegrees lat = [_targetList[i][EVENT_LAT_KEY] doubleValue];
            CLLocationDegrees lon = [_targetList[i][EVENT_LON_KEY] doubleValue];
            location = CLLocationCoordinate2DMake(lat, lon);
            if (CLLocationCoordinate2DIsValid(location)){
                annotation = [MemberPointAnnotation new];
                [annotation setDistance:[[LocationManager shareInstance] distanceFromLocationUsingLongitude:lon Latitude:lat]];
                [annotation setTitle:_targetList[i][EVENT_TITLE_KEY]];
                [annotation setCoordinate:location];
                [annotation setTag:i];
                
                
                [_mapview addAnnotation:annotation];
            }
            
        }
    }

}



- (void) showDirection : (CLLocationCoordinate2D) destination {
    MKPlacemark * destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination];
    MKMapItem * destinationMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    MKDirectionsRequest * directionRequest = [MKDirectionsRequest new];
    MKMapItem * sourceMapItem = [MKMapItem mapItemForCurrentLocation];
    
    [directionRequest setTransportType:transportationType];
    [directionRequest setDestination:destinationMapItem];
    [directionRequest setSource:sourceMapItem];
    
    MKDirections * directions = [[MKDirections alloc] initWithRequest:directionRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (error){
            NSLog(@"ERROR in MKDirections : %@", error);
            return;
        }
        _currentRoute = [response.routes firstObject];
        [self plotRouteOnMap:_currentRoute];
    }];
    
}

- (void) plotRouteOnMap: (MKRoute *) route {
    if (_routeOverlay){
        [_mapview removeOverlay:_routeOverlay];
    }
    
    // Update
    _routeOverlay = route.polyline;
    _routeStep = route.steps;
    [_mapview addOverlay:_routeOverlay level:MKOverlayLevelAboveRoads];
    
    if (_currentVC && [_currentVC isKindOfClass:[MemberDetailViewController class]]){
        [((MemberDetailViewController *) _currentVC) setNextStep:[NSString stringWithFormat:@"%@", _routeStep.firstObject.instructions]];
    }

}

/// GET ESTIMATED TIME of ARRIVAL
- (void) getETA : (CLLocationCoordinate2D) destination withDonehandler: (MKETAHandler) handler {
    MKPlacemark * destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination];
    MKMapItem * destinationMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    MKDirectionsRequest * directionRequest = [MKDirectionsRequest new];
    
    [directionRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    [directionRequest setDestination:destinationMapItem];
    [directionRequest setTransportType:transportationType];
    
    MKDirections * directions = [[MKDirections alloc] initWithRequest:directionRequest];
    [directions calculateETAWithCompletionHandler:handler];
}

#pragma mark - SETUPs
- (void) setupInfo {
    // 0. setup GENERAL GROUP LIST
    
    _friendListDict = [NSMutableDictionary new]; // contains friend lists of a given group
    _targetFriendList = [NSMutableArray new]; //
    _targetList = [NSMutableArray new]; // contains the group of interest
    _groupList = [NSMutableArray new]; // contains the groups' info
    _eventList = [NSMutableArray new]; // contains the events' info
    _generalGroupList = @[@"目前位置",
                          @"個人群組",
                          @"其他群組",
                          @"我的活動"];
    
    // 1. update the Database from Server
    [DataManager updateContactDatabase:^(BOOL done) {
        if (done){
            // 2. setup GROUP_LIST
            [_groupList addObject: [DataManager fetchGroupsFromTableWithRole:1]];
            [_groupList addObject: [DataManager fetchGroupsFromTableWithRole:-1]];
            
            NSMutableArray * tempGroups = [NSMutableArray new];
            [tempGroups addObjectsFromArray:[DataManager fetchDatabaseFromTable:GROUP_LIST_TABLE]];
            
            // 3. setup FRIEND_LIST (based on GROUPS)
            for (int i = 0; i < tempGroups.count; i++)
            {
                NSInteger groupID = [tempGroups[i][GROUP_ID_KEY] integerValue];
                NSArray * tempArray = [[NSArray alloc] initWithArray:[DataManager fetchUserInfoFromTableWithGroupID:groupID]];
                [_friendListDict setObject:tempArray forKey:@(groupID)];
            }
            
            // 4. setup EVENT_LIST
            [_eventList addObject:[DataManager fetchEventsFromTable]];
        }
    }];
    
}

- (void) setSubView: (UIViewController *) vc {
    // Remove all subviews
    for (UIView * view in [_memberDetailView subviews]) {[view removeFromSuperview];}
    
    // Check if there is _currentVC
    if (_currentVC) {
        [_currentVC willMoveToParentViewController:nil];
    } else {
        [vc willMoveToParentViewController:self];
        [self addChildViewController:vc];
    }
    
    // add vc to _memberDetailView and displays it
    [vc.view setFrame:(CGRect){{0,0},_memberDetailView.frame.size}];
    
    [_memberDetailView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_memberDetailView setClipsToBounds:true];
    [_memberDetailView addSubview:vc.view];
    [_memberDetailView setHidden:false];
    
    _currentVC = vc;
}

#pragma mark - Annotations for HOSPITAL and POLICE STATION
- (void) hospitalSearch : (CLLocationCoordinate2D) location {
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    MKLocalSearchRequest * request = [MKLocalSearchRequest new];
    NSString * naturalLanguageQuery = @"hospital";
    
    [request setNaturalLanguageQuery:naturalLanguageQuery];
    [request setRegion:region];
    
    MKLocalSearch * localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        if (error){
            NSLog(@"Error : %@", error);
            return;
        }
        
        NSMutableArray * annotations = [NSMutableArray new];
        [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.name){
                
                CustomPointAnnotation * annotation = [CustomPointAnnotation new];
                
                [annotation setAddress:obj.placemark.addressDictionary[UITextContentTypeFullStreetAddress]];
                [annotation setImage:[UIImage imageNamed:@"Hospital Annotation"]];
                [annotation setCoordinate:obj.placemark.coordinate];
                [annotation setType:naturalLanguageQuery];
                [annotation setPhone:obj.phoneNumber];
                [annotation setTitle:obj.name];
  
                [annotations addObject:annotation];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapview addAnnotations:annotations];
        });
    }];
}

- (void) policsStationSearch : (CLLocationCoordinate2D) location {
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1,0.1);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    MKLocalSearchRequest * request = [MKLocalSearchRequest new];
    NSString * naturalLanguageQuery = @"police";
    
    [request setNaturalLanguageQuery:naturalLanguageQuery];
    [request setRegion:region];
    
    MKLocalSearch * localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        if (error){
            NSLog(@"Error : %@", error);
            return;
        }
        
        NSMutableArray * annotations = [NSMutableArray new];
        [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.name){
                CustomPointAnnotation * annotation = [CustomPointAnnotation new];
                [annotation setAddress:obj.placemark.addressDictionary[UITextContentTypeFullStreetAddress]];
                [annotation setImage:[UIImage imageNamed:@"Police Station Annotation"]];
                [annotation setCoordinate:obj.placemark.coordinate];
                [annotation setType:naturalLanguageQuery];
                [annotation setPhone:obj.phoneNumber];
                [annotation setTitle:obj.name];
                
                [annotations addObject:annotation];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapview addAnnotations:annotations];
        });
    }];
}

-(void)dealloc {
    NSLog(@"MAP RELEASE");
    NSLog(@"TestViewController Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef) self));
}


@end
