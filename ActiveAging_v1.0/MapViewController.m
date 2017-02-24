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
#import "SQLite3DBManager.h"
#import "LocationManager.h"
#import "ImageManager.h"
#import "UserInfo.h"
#import "ContactTableViewCell.h"
#import "MemberDetailViewController.h"
#import "MemberAnnotationView.h"
#import "MemberPointAnnotation.h"
#import <MapKit/MapKit.h>
#import "MKMapView+Autoadjustment.h"



typedef enum : NSUInteger {
    noSelection,
    personalGroups,
    otherGroups,
    activities,
} GeneralGroups;

typedef void (^MKETAHandler)(MKETAResponse * __nullable response, NSError * __nullable error);

@interface MapViewController () <MKMapViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, LocationManagerDelegate, MemberDetailViewControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerview;
@property (weak, nonatomic) IBOutlet UIView *groupView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *memberDetailView;
@property (weak, nonatomic) IBOutlet UISwitch *shareLocationSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionStyleSwitcher;

@property (strong, nonatomic) NSArray * generalGroupList;
@property (strong, nonatomic) NSMutableArray * groupList;
@property (strong, nonatomic) NSMutableArray * targetGroupList;
@property (strong, nonatomic) NSMutableDictionary * friendListDict;
@property (strong, nonatomic) NSMutableArray * targetFriendList;
@property (strong, nonatomic) NSMutableArray * eventsLocations;
@property (strong, nonatomic) NSMutableArray * hospitalLocations;
@property (strong, nonatomic) NSMutableArray * policeStationLocations;

@property (strong, nonatomic) MKRoute * currentRoute;
@property (strong, nonatomic) MKPolyline * routeOverlay;
@property (strong, nonatomic) NSArray <MKRouteStep *> * routeStep;
@property (strong, nonatomic) UIViewController * currentVC;
@property (assign) CLLocationCoordinate2D targetLocation;
@end

@implementation MapViewController{
    
    ServerManager * _serverMgr;
    LocationManager * _locationMgr;
    UserInfo * _userInfo;
    CLLocation * specificLocation;
    MKPolyline * polyLine;
    MKDirectionsTransportType transportationType;
    
    BOOL shareLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // SETUP SINGLETONs
    _locationMgr = [LocationManager shareInstance];
    if (_locationMgr.accessGranted){
        [_locationMgr startUpdatingLocation];
    }
    _locationMgr.delegate = self;
    _userInfo = [UserInfo shareInstance];
    
    
    // Prepare data
    [DataManager updateContactDatabase];
    shareLocation = [[[NSUserDefaults standardUserDefaults]
                      objectForKey:@"shareLocation"] boolValue];
    
    // SETUP VIEWS
    [_mapview setShowsUserLocation:true];
    [_mapview setDelegate:self];
    [_pickerview setDelegate:self];
    [_pickerview setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_groupView setHidden:true];
    [_memberDetailView setHidden:true];
    [_shareLocationSwitch setOn:shareLocation];
    
    [self setupInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [[LocationManager shareInstance] startUpdatingLocation];
}

-(void)viewDidAppear:(BOOL)animated{
    [_mapview locatePointA:_locationMgr.location.coordinate];
}


#pragma mark - LOCATION MANAGER
- (void) locationControllerDidUpdateLocation: (CLLocation *) location{
    
    // Update the database
    [DataManager updateContactDatabase];
    
    if ([_currentVC isKindOfClass:[MemberDetailViewController class]] && ![_memberDetailView isHidden]){
        NSInteger userID = ((MemberDetailViewController *) _currentVC).userID;
        NSArray * tempArray = [DataManager fetchUserInfoFromTableWithUserID:userID];
        NSLog(@"tempArray : %@", tempArray);
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
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    // return nil if annotation @ userLocation
    if (annotation == mapView.userLocation){
        return nil;
    }
    
    float distance = ((MemberAnnotationView *) annotation).distance;
    MemberAnnotationView * pin = [[MemberAnnotationView alloc] initWithAnnotation:annotation distance:distance];
    
    return pin;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer * line = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    [line setLineWidth:5.0];
    [line setStrokeColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5]];
    return line;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    [_mapview setRegionBetweenA:[view.annotation coordinate] andB:_locationMgr.location.coordinate];
    
    _targetLocation = view.annotation.coordinate;
    [self showDirection:_targetLocation];
}

#pragma mark - PICKER
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0)
    {
        return _generalGroupList.count;
    }
    return _targetGroupList.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (component == 0)
    {
        return _generalGroupList[row];
    }
    return _targetGroupList[row][GROUP_NAME_KEY];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    [_mapview removeAnnotations:_mapview.annotations];
    
    if (component == 0)
    {
        // User pick the GENERAL group
        _targetGroupList = [NSMutableArray new];
        [_targetGroupList addObject:@{GROUP_ID_KEY:@(0),
                                      GROUP_NAME_KEY: @"請選組",
                                      USER_ROLE_KEY:@(0)}];
        switch (row) {
            case personalGroups:
                [_targetGroupList addObjectsFromArray:_groupList[0]];
                break;
            case otherGroups:
                [_targetGroupList addObjectsFromArray:_groupList[1]];
                break;
            case activities: // need to set another SQL_Table?
                _targetGroupList = [NSMutableArray new];
                break;
            default:
                _targetGroupList = [NSMutableArray new];
                [_mapview locatePointA:_locationMgr.location.coordinate];
                break;
        }
        [_pickerview reloadComponent:1];
        [_pickerview selectRow:0 inComponent:1 animated:true];
    }
    else{
        _targetFriendList = [NSMutableArray new];
        [_targetFriendList addObject:@{USER_NAME_KEY:@"全部"}];
        if (_targetGroupList.count > 1){
            NSInteger groupID = [_targetGroupList[row][GROUP_ID_KEY] integerValue];
            if (groupID == 0)
            {
                _targetFriendList = [NSMutableArray new];
                [_groupView setHidden:true];
                [_directionStyleSwitcher setHidden:false];
            }
            else
            {
                [_targetFriendList addObjectsFromArray:_friendListDict[@(groupID)]];
                [_groupView setHidden:false];
                [_directionStyleSwitcher setHidden:true];
                [_tableView reloadData];
            }
        }
    }
    
}




#pragma mark - TABLEVIEW
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _targetFriendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    
    cell.titleLabel.text = _targetFriendList[indexPath.row][USER_NAME_KEY];
    [cell.titleLabel setNumberOfLines:0];
    if (indexPath.row == 0){
        cell.subtitleLabel.text = @"";
    }
    else{
        if (_targetFriendList[indexPath.row][USER_CUR_LON_KEY] != [NSNull null]
            && _targetFriendList[indexPath.row][USER_CUR_LAT_KEY] != [NSNull null]){
            
            CLLocationDegrees lon = [_targetFriendList[indexPath.row][USER_CUR_LON_KEY] doubleValue];
            CLLocationDegrees lat = [_targetFriendList[indexPath.row][USER_CUR_LAT_KEY] doubleValue];
            
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
            
            [self getETA:location withDonehandler:^(MKETAResponse * _Nullable response, NSError * _Nullable error) {
                NSString * expectedTime = @"";
                if (error){
                    expectedTime = @"UNKNONW";
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
                        expectedTime = @"太遠了";
                    }
                    [cell.subtitleLabel setNumberOfLines:0];
                    cell.subtitleLabel.text = expectedTime;
                }
            }];
        }
        else {
            cell.subtitleLabel.text = @"UNKNOWN";
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
        for (int i = 1; i < _targetFriendList.count; i++){
            [coordinates addObject:@[_targetFriendList[i][USER_CUR_LAT_KEY], _targetFriendList[i][USER_CUR_LON_KEY]]];
        }
        
        [coordinates addObject:@[@(_locationMgr.location.coordinate.latitude), @(_locationMgr.location.coordinate.longitude)]];
        
        [_mapview recenterMap:coordinates];
        [_mapview removeOverlay:_routeOverlay];
    }
    else
    {
        if (![cell.detailTextLabel.text isEqualToString:@"UNKNOWN"]){
            lon = [_targetFriendList[indexPath.row][USER_CUR_LON_KEY] doubleValue];
            lat = [_targetFriendList[indexPath.row][USER_CUR_LAT_KEY] doubleValue];
            _targetLocation = CLLocationCoordinate2DMake(lat, lon);
            [_mapview setRegionBetweenA:_targetLocation andB:_locationMgr.location.coordinate];
            
            [self showDirection:_targetLocation];
            
            MemberDetailViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MemberDetailViewController"];
            vc.delegate = self;
            vc.userID = [_targetFriendList[indexPath.row][USER_ID_KEY] integerValue];
            
            [self setSubView:vc];
            
        }
    }
    [_mapview removeAnnotations:_mapview.annotations];
    [self showFriendAnnotation];
    [_directionStyleSwitcher setHidden:false];
    
}

/// MARK: TABLE_VIEW_PROPERTIES
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.0;
}



#pragma mark - BUTTONS
- (IBAction)returnButtonPresssed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)shouldShareLocationSwitch:(id)sender {
    if (shareLocation){
        shareLocation = !shareLocation;
        [_userInfo changeShareLocation];
    }
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
- (void) showFriendAnnotation {
    if (_targetFriendList.count > 0){
        
        MemberPointAnnotation * annotation;
        CLLocationCoordinate2D location;
        
        for (int i = 1; i < _targetFriendList.count; i++){
            
            if (_targetFriendList[i][USER_CUR_LAT_KEY] != [NSNull null] && _targetFriendList[i][USER_CUR_LON_KEY] != [NSNull null]){
            
                CLLocationDegrees lat = [_targetFriendList[i][USER_CUR_LAT_KEY] doubleValue];
                CLLocationDegrees lon = [_targetFriendList[i][USER_CUR_LON_KEY] doubleValue];
                location = CLLocationCoordinate2DMake(lat, lon);
                annotation = [MemberPointAnnotation new];
                
                [annotation setTitle:_targetFriendList[i][USER_NAME_KEY]];
                [annotation setCoordinate:location];
                annotation.distance = [_locationMgr distanceFromLocationUsingLongitude:lon Latitude:lat];
                
                [_mapview addAnnotation:annotation];
            }
        }
        
    }

}


- (void) showDirection : (CLLocationCoordinate2D) destination {
    MKDirectionsRequest * directionRequest = [MKDirectionsRequest new];
    MKMapItem * sourceMapItem = [MKMapItem mapItemForCurrentLocation];
    MKPlacemark * destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination];
    MKMapItem * destinationMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    [directionRequest setSource:sourceMapItem];
    [directionRequest setDestination:destinationMapItem];
    [directionRequest setTransportType:transportationType];
    
    MKDirections * directions = [[MKDirections alloc] initWithRequest:directionRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (error){
            NSLog(@"ERRROR in MKDirections : %@", error);
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
    [_mapview addOverlay:_routeOverlay level:MKOverlayLevelAboveRoads];
    
    _routeStep = route.steps;
    
    if (_currentVC && [_currentVC isKindOfClass:[MemberDetailViewController class]]){
        [((MemberDetailViewController *) _currentVC) setNextStep:[NSString stringWithFormat:@"%@", _routeStep.firstObject.instructions]];
    }

}

/// GET ESTIMATED TIME of ARRIVAL
- (void) getETA : (CLLocationCoordinate2D) destination withDonehandler: (MKETAHandler) handler {
    MKDirectionsRequest * directionRequest = [MKDirectionsRequest new];
    [directionRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    MKPlacemark * destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination];
    MKMapItem * destinationMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    [directionRequest setDestination:destinationMapItem];
    [directionRequest setTransportType:transportationType];
    MKDirections * directions = [[MKDirections alloc] initWithRequest:directionRequest];
    [directions calculateETAWithCompletionHandler:handler];
}

#pragma mark - SETUPs
- (void) setupInfo {
    // 0. setup GENERAL GROUP LIST
    _generalGroupList = @[@"請選擇",
                          @"個人群組",
                          @"其他群組",
                          @"我的活動",
                          @"顯示全部"];
    
    
    _groupList = [NSMutableArray new]; // contains the groups' name
    _friendListDict = [NSMutableDictionary new];
    _targetGroupList = [NSMutableArray new];
    _targetFriendList = [NSMutableArray new];
    
    // 1. update the Database from Server
    [DataManager updateContactDatabase];
    
    // 2. setup GROUP_LIST
//    [_groupList addObjectsFromArray:[DataManager fetchDatabaseFromTable:GROUP_LIST_TABLE]];
    
    [_groupList addObject: [DataManager fetchGroupsFromTableWithRole:1]];
    [_groupList addObject: [DataManager fetchGroupsFromTableWithRole:-1]];
    
    NSMutableArray * tempGroups = [NSMutableArray new];
    [tempGroups addObjectsFromArray:[DataManager fetchDatabaseFromTable:GROUP_LIST_TABLE]];
    
    // 3. setup FRIEND_LIST (based on GROUPS)
    for (int i = 0; i < tempGroups.count; i++){
        NSInteger groupID = [tempGroups[i][GROUP_ID_KEY] integerValue];
        NSArray * tempArray = [[NSArray alloc] initWithArray:[DataManager fetchUserInfoFromTableWithGroupID:groupID]];
        [_friendListDict setObject:tempArray forKey:@(groupID)];
    }
}

- (void) setSubView: (UIViewController *) vc {
    for (UIView * view in [_memberDetailView subviews])
    {
        [view removeFromSuperview];
    }
    
    if (_currentVC)
    {
        [_currentVC willMoveToParentViewController:nil];
    }
    else
    {
        [vc willMoveToParentViewController:self];
        
        [self addChildViewController:vc];
    }
    
    [vc.view setFrame:(CGRect){{0,0},_memberDetailView.frame.size}];
    [_memberDetailView addSubview:vc.view];
    [_memberDetailView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_memberDetailView setClipsToBounds:true];
    _currentVC = vc;
    [_memberDetailView setHidden:false];
    
}



#pragma mark - MemberDetailView Delegate


@end
