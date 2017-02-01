//
//  MapViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/24/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "MapViewController.h"
#import "ServerManager.h"
#import "SQLite3DBManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


static dispatch_once_t onceToken;
@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerview;
@property (weak, nonatomic) IBOutlet UIView *groupView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MapViewController{
    
    ServerManager * _serverMgr;
    
    CLLocationManager * cllocationMgr;
    MKAnnotationView * mkAnnotation;
    CLLocation * specificLocation;
    MKPolyline * polyLine;
    
    BOOL shareLocation;
    NSArray * dummyArray;
    NSDictionary * dummyDictionary;
    NSString * chosenGroup;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    cllocationMgr = [CLLocationManager new];
    [_mapview setShowsUserLocation:true];
    shareLocation = false;
    
//    UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
//    [tap addTarget:self action:@selector(endEditing)];
//    [self.view addGestureRecognizer:tap];
    
    
    // REQUEST PERMISSION
    if([cllocationMgr respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [cllocationMgr requestWhenInUseAuthorization];
        _mapview.delegate = self;
    }else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"錯誤" message:@"請允許我們用您的定位系統以便讓您享用我們ＡＰＰ的完整服務" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [cllocationMgr setDesiredAccuracy:kCLLocationAccuracyBest];
    [cllocationMgr setActivityType:CLActivityTypeAutomotiveNavigation];
    [cllocationMgr setAllowsBackgroundLocationUpdates:true];
    cllocationMgr.delegate = self;
    [cllocationMgr startUpdatingLocation];
    
    
    
    // SETUP PICKERVIEW
    _pickerview.delegate = self;
    _pickerview.dataSource = self;
    
    // SETUP TABLEVIEW
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    
    // SETUP GROUP_VIEW
    [_groupView setHidden:true];
    
    
    // SETUP the DUMMY DICTIONARY FOR LATER USE
    /*
     self needed:
     // shall be saved in local database
     1. group_ID
     2. role
     
     keys needed are:
     1. group_ID
     1. user_ID
     2. user_Name
     3. user_Lon
     4. user_Lat
     5. user_PIC
     */
    
    NSArray * group1 = @[
  @{USER_ID_KEY:@"100",
    USER_NAME_KEY:@"AlbertLEE",
    USER_CUR_LAT_KEY:@"23",
    USER_CUR_LON_KEY:@"120"},
  @{USER_ID_KEY:@"101",
    USER_NAME_KEY:@"AlexALA",
    USER_CUR_LAT_KEY:@"34",
    USER_CUR_LON_KEY:@"120"},
  @{USER_ID_KEY:@"102",
    USER_NAME_KEY:@"AmyMcDonald",
    USER_CUR_LAT_KEY:@"34",
    USER_CUR_LON_KEY:@"120"},
  @{USER_ID_KEY:@"103",
    USER_NAME_KEY:@"Adam",
    USER_CUR_LAT_KEY:@"34",
    USER_CUR_LON_KEY:@"120"}];
    
    NSArray * group2 = @[
  @{USER_ID_KEY:@"104",
    USER_NAME_KEY:@"BenEthen",
    USER_CUR_LAT_KEY:@"23",
    USER_CUR_LON_KEY:@"120"},
  @{USER_ID_KEY:@"105",
    USER_NAME_KEY:@"BakeryLoaf",
    USER_CUR_LAT_KEY:@"34",
    USER_CUR_LON_KEY:@"120"},
  @{USER_ID_KEY:@"106",
    USER_NAME_KEY:@"BackStabber",
    USER_CUR_LAT_KEY:@"34",
    USER_CUR_LON_KEY:@"120"},
  @{USER_ID_KEY:@"107",
    USER_NAME_KEY:@"BackToSchool",
    USER_CUR_LAT_KEY:@"34",
    USER_CUR_LON_KEY:@"120"}];
    
    NSArray * group3 = @[
  @{USER_ID_KEY:@"108",
    USER_NAME_KEY:@"CatLady",
    USER_CUR_LAT_KEY:@"23",
    USER_CUR_LON_KEY:@"120"},
  @{USER_ID_KEY:@"109",
    USER_NAME_KEY:@"CattaPuss",
    USER_CUR_LAT_KEY:@"34",
    USER_CUR_LON_KEY:@"120"},
  @{USER_ID_KEY:@"110",
    USER_NAME_KEY:@"CalvinKen",
    USER_CUR_LAT_KEY:@"34",
    USER_CUR_LON_KEY:@"120"},
  @{USER_ID_KEY:@"111",
    USER_NAME_KEY:@"CloverChan",
    USER_CUR_LAT_KEY:@"34",
    USER_CUR_LON_KEY:@"120"}];
    
    
    
    dummyDictionary = @{@"groups":@[@"group1",@"group2",@"group3"],
                        @"group1":group1,
                        @"group2":group2,
                        @"group3":group3};
    dummyArray = dummyDictionary[@"groups"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [cllocationMgr startUpdatingLocation];
}


#pragma mark - MAP
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    static NSString * pinAnnotation = @"friend";
    
    if (annotation == mapView.userLocation){
        return nil;
    }
    
    MKPinAnnotationView * pinView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:pinAnnotation];
    
    // set the PIN
    if (pinView == nil){
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinAnnotation];
    } else {
        pinView.annotation = annotation;
    }
    [pinView setCanShowCallout:true];
    return pinView;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer * line = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
    [line setLineWidth:7.0];
    return line;
}


#pragma mark - CLLOCATION
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation * myLocation = locations.lastObject;
    
    CLLocationCoordinate2D myCoordinate = CLLocationCoordinate2DMake(myLocation.coordinate.latitude, myLocation.coordinate.longitude);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    
    MKCoordinateRegion  region = MKCoordinateRegionMake(myCoordinate, span);
    
    dispatch_once(&onceToken, ^{
        [_mapview setRegion:region];
        [self showFriendAnnotation];
    });
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    
}

#pragma mark - PICKER
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return dummyArray.count+1;
}

//-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
//    
//}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSMutableArray * tempArray = [NSMutableArray new];
    
    [tempArray addObject:@"請選擇"];
    [tempArray addObjectsFromArray:dummyArray];
    return  tempArray[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (row != 0){
        row = row-1;
        chosenGroup = dummyArray[row];
        [_groupView setHidden:false];
        [_tableView reloadData];
    } else {
        [_groupView setHidden:true];
        onceToken = 0;
    }
}




#pragma mark - TABLEVIEW
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray * tempArray = dummyDictionary[chosenGroup];
    return tempArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray * tempArray = dummyDictionary[chosenGroup];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.textLabel.text = tempArray[indexPath.row][USER_NAME_KEY];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@,%@", tempArray[indexPath.row][USER_CUR_LAT_KEY], tempArray[indexPath.row][USER_CUR_LON_KEY]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [_groupView setHidden:true];
    
    NSArray * memberArray = dummyDictionary[chosenGroup];
    
    CLLocationDegrees lat = [memberArray[indexPath.row][USER_CUR_LAT_KEY] doubleValue];
    CLLocationDegrees lon = [memberArray[indexPath.row][USER_CUR_LON_KEY] doubleValue];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
//    MKOverlayRenderer 
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    [_mapview setRegion:region];
}


#pragma mark - BUTTONS
- (IBAction)returnButtonPresssed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)shouldShareLocationSwitch:(id)sender {
    if (shareLocation){
        shareLocation = !shareLocation;
    }
}


#pragma mark - PRIVATE METHODS
- (void) showFriendAnnotation{
    NSArray * keys = [[NSArray alloc] initWithArray:dummyDictionary[@"groups"]];
    
    for (int i = 0; i<keys.count; i++){
        NSArray * tempArray = dummyDictionary[keys[i]];
        CLLocationCoordinate2D location;
        MKPointAnnotation * friendPAnnotation;
        for (int i = 0; i < tempArray.count ; i++){
            CLLocationDegrees lat = [tempArray[i][USER_CUR_LAT_KEY] doubleValue];
            CLLocationDegrees lon = [tempArray[i][USER_CUR_LON_KEY] doubleValue];
            
            location = CLLocationCoordinate2DMake(lat, lon);
            //        MKPinAnnotationView *
            
            friendPAnnotation = [MKPointAnnotation new];
            [friendPAnnotation setTitle:tempArray[i][USER_NAME_KEY]];
            [friendPAnnotation setCoordinate:location];
        }
        [friendPAnnotation setSubtitle:keys[i]];
        [_mapview addAnnotation:friendPAnnotation];

    }
}

- (void) endEditing{
    [self.view endEditing:true];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
