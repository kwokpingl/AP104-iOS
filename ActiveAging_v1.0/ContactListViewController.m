//
//  ContactListViewController.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/1.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "ContactListViewController.h"
#import "ContactTableViewCell.h"
#import "SubViewController.h"

#import "ServerManager.h"
#import "UserInfo.h"
//#import "SQLite3DBManager.h"
#import "DataManager.h"
#import "ImageManager.h"
#import "LocationManager.h"


typedef enum {
    viewAddMember,
    viewCreateGroup,
    alertAddMember,
    alertAddEmergency,
    alertCreateGroup,
    alertQuitGroup
} viewTypes;

typedef enum {
    okBarButton,
    cancelBarButton,
    returnBarButton
} barButtonItem;

typedef enum {
    personalGroup,
    otherGroup,
    emergencyGroup
}groupType;

static NSInteger layer;

@interface ContactListViewController ()<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate>{
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    LocationManager * _locationMgr;
    
    CLLocationManager * clMgr;
    CLLocation * currentLocation;
    
    // LISTS
    NSMutableArray * contactList;
    NSMutableArray * personalGroupList;
    NSMutableArray * otherGroupList;
    NSMutableArray * emergencyList;
    
    NSMutableArray * targetList;
    NSArray * pickerViewArray;
    NSString * targetKey;
    
    // Trackers
    NSInteger personalGroupNumber;
    NSInteger emergencyMemberNumber;
    NSInteger role;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIPickerView * pickerView;
@property (weak, nonatomic) IBOutlet UIView *subView;
@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initiate Singletons
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    
//    _sqlMgr = [[SQLite3DBManager alloc] initWithDatabaseFilename:MOBILE_DATABASE];
    
    // ask for PERMISSION
    // set up CLLocation Manager
    if ([CLLocationManager locationServicesEnabled]){
        _locationMgr = [LocationManager shareInstance];
    }
    else{
        [self presentViewController:[_locationMgr serviceEnableAlert] animated:true completion:nil];
    }
    
    [_locationMgr startUpdatingLocation];
    [_locationMgr addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    // SETUP DELEGATE / DATASOURCE
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    // SETUP PICKER ARRAY
    pickerViewArray = @[@"個人群組",@"其他群組",@"緊急聯絡人"];
    personalGroupNumber = 0;
    
    // UPDATE THE DATABASE
    [DataManager updateContactDatabase];
    contactList = [DataManager fetchDatabaseFromTable: CONTACT_LIST_TABLE];
    
    [self reloadGroupList];
    
    // SETUP NAVIGATION BAR
    UIBarButtonItem * returnBtn =
    [[UIBarButtonItem alloc] initWithTitle:@"<回首頁" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView:)];
    [returnBtn setTag:returnBarButton];
    [self.navigationItem setLeftBarButtonItem:returnBtn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
    // GET PICKERVIEW READY
    [_pickerView selectRow:0 inComponent:0 animated:true];
    [self pickerView:_pickerView didSelectRow:0 inComponent:0];
}

- (void)viewWillDisappear:(BOOL)animated{
    [_locationMgr removeObserver:self forKeyPath:@"currentLocation"];
    [_locationMgr stopUpdatingLocation];
}

#pragma mark - === TABLEVIEW ===
/// MARK: SETUPs
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return targetList.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.0;
}

/// MARK: TABLEVIEWCELL
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.subtitleLabel setHidden:false];
    // IF I CHOOSE FROM PICKER
    if (layer == 0){
        cell.titleLabel.text = targetList[indexPath.section][targetKey];
        
        if ([targetList[indexPath.section][USER_ROLE_KEY] integerValue] == 1){
            [cell.subtitleLabel setText:@"刪除群組"];
        }
        else if ([targetList[indexPath.section][USER_ROLE_KEY] integerValue] == -1){
            [cell.subtitleLabel setText:@"退出群組"];
        }
        else{
            [cell.subtitleLabel setHidden:true];
        }
        
        cell.subtitleLabel.tintColor = [UIColor redColor];
        
        [cell.imageView setHidden:true];
    }
    
    // IF I CHOOSE FROM TABLE
    else if (layer == 1){
        targetKey = USER_NAME_KEY;
        cell.titleLabel.text = targetList[indexPath.section][targetKey];
        
        NSString * subTitle;
        NSInteger userID = [targetList[indexPath.section][USER_ID_KEY] integerValue];
        // Valid User
        if (userID > 0){
            [cell.imageView setHidden:false];
            [ImageManager getUserImage:userID completion:^(NSError *error, id result) {
                if (error){
                    cell.imageView.image = nil;
                }else{
                    cell.imageView.image = [UIImage imageWithData:result];
                }
            }];
            
            
            // check location
            CLLocationDegrees longitude = [targetList[indexPath.section][USER_CUR_LON_KEY] doubleValue];
            CLLocationDegrees latitude = [targetList[indexPath.section][USER_CUR_LAT_KEY] doubleValue];
            
            [cell.subtitleLabel setHidden:false];
            
            if (fabs(latitude)<=90 && fabs(longitude)<=180){
                
                double distance = [_locationMgr distanceFromLocationUsingLongitude:longitude Latitude:latitude];
                
                subTitle = [NSString stringWithFormat:@"距離%.2f公里",distance];
            }
            else{
                subTitle = @"???";
            }
            
            
        }
        
        [cell.subtitleLabel setText:subTitle];
    }
    
    return cell;
}

/// MARK: SELECT_TABLE_CELL
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (layer == 0){
        if ([targetList[indexPath.section][GROUP_ID_KEY] integerValue] == 0){
         // SHOW ALERT for CREATING GROUP
            [self showView:viewCreateGroup];
            
            
        }else{
            [self getContact:indexPath.section];
            layer ++;
        }
    }
    
    if (layer > 1){
        [_pickerView selectRow:0 inComponent:0 animated:true];
        [self pickerView:_pickerView didSelectRow:0 inComponent:0];
    }
  
    NSLog(@"LAYER: %ld", layer);
    
    [_tableView reloadData];
    
    }




#pragma mark - === PICKER_VIEW ===
/// MARK: SETUP_PICKERVIEW
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pickerViewArray.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 60;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel * labelView = (UILabel *) view;
    if (!labelView){
        labelView = [UILabel new];
        
        UIFont * font = [UIFont systemFontOfSize:25.0 weight:30.0];
        
        [labelView setFont:font];
        [labelView setText:pickerViewArray[row]];
        [labelView setTextAlignment:NSTextAlignmentCenter];
    }
    
    return labelView;
}


/// MARK: PICKERVIEW_WHEN_SELECTED
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    targetList = [NSMutableArray new];
    [self getGroup:row];
    [_tableView reloadData];
}



#pragma mark - === PRIVATE METHOD ===

/// MARK: RELOAD_GROUP_LIST
- (void) reloadGroupList{
    personalGroupList = [[NSMutableArray alloc] initWithArray:[DataManager fetchGroupsFromTableWithRole:1]];
    otherGroupList = [[NSMutableArray alloc] initWithArray:[DataManager fetchGroupsFromTableWithRole:-1]];
    emergencyList = [[NSMutableArray alloc] initWithArray:[DataManager fetchDatabaseFromTable:EMERGENCY_TABLE]];
    contactList = [NSMutableArray new];
    
    contactList = [DataManager fetchDatabaseFromTable:CONTACT_LIST_TABLE];
    
}

/// MARK: GET_THE_GROUP_LISTS
- (void) getGroup: (NSInteger) group {
    targetList = [NSMutableArray new];
    layer = 0;
    switch (group) {
        case personalGroup:
            targetKey = GROUP_NAME_KEY;
            [targetList addObjectsFromArray: personalGroupList];
            personalGroupNumber = targetList.count;
            break;
        case otherGroup:
            targetKey = GROUP_NAME_KEY;
            [targetList addObjectsFromArray: otherGroupList];
            break;
        case emergencyGroup:
            targetKey = USER_NAME_KEY;
            [targetList addObjectsFromArray: emergencyList];
            emergencyMemberNumber = targetList.count;
            break;
        default:
            NSLog(@"Something Wrong");
            break;
    }
    
    if(group == personalGroup && personalGroupNumber < 3){
        NSString * message = [NSString stringWithFormat:@"+ 尚可新增 %ld 群組", MAXIMUM_PERSONAL_GROUP - personalGroupNumber];
        [targetList
         addObject:@{
                     GROUP_ID_KEY:@(0),
                     targetKey:message,
                     USER_ROLE_KEY:@(0)}];
    }
    
}

/// MARK: GET_CONTACT_A_GROUP
- (void) getContact: (NSInteger) groupRow{
    
    NSString * groupName = targetList[groupRow][GROUP_NAME_KEY];
    NSInteger groupID = [targetList[groupRow][GROUP_ID_KEY] integerValue];
    role = [targetList[groupRow][USER_ROLE_KEY] integerValue];
    
    targetList = [NSMutableArray new];
    
    [self.navigationItem setTitle:groupName];
    
    [targetList addObjectsFromArray:[DataManager fetchUserInfoFromTableWithGroupID:groupID]];
    
    if (role == 1){
        [targetList addObject:
  @{USER_ID_KEY:@(-3),
    USER_NAME_KEY:@"+ 新增組員"}];
    }
    
}







#pragma mark - ALERTS
- (void) showAlert: (NSInteger) alertType{
    
    UIAlertController * alert;
    NSString * alertTitle;
    NSString * alertMessage;
    NSString * okMessage;
    UIAlertControllerStyle alertStyle;
    
    
    switch (alertType) {
        case alertCreateGroup:
        {
        }
            break;
        case alertQuitGroup:
            break;
        case alertAddMember:
            break;
        case alertAddEmergency:
            break;
        default:
            break;
    }
//    [self presentViewController:alert animated:true completion:nil];
}

/// MARK: SHOW_UIVIEW_WHEN_CREATEGROUPS
- (void) showView:(NSInteger) viewTypes{
    switch (viewTypes) {
        case viewCreateGroup:
        {
            UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SubViewController"];
            vc.view.frame = _subView.frame;
            vc.view.center = CGPointMake(_subView.frame.size.width/2.0, _subView.frame.size.height/2.0);
            [_subView addSubview:vc.view];
            
            [self addChildViewController:vc];
            [vc didMoveToParentViewController:self];
            [_pickerView setUserInteractionEnabled:false];
            UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView:)];
            [cancelBtn setTag:cancelBarButton];
            [self.navigationItem setLeftBarButtonItem:cancelBtn];
        }
            break;
            
        default:
            break;
    }
}


- (void) endEditing:(id) sender{
    [self.view endEditing:true];
}

- (void) dismissView: (id)sender{
    if ([sender isKindOfClass:[UIBarButtonItem class]]){
        UIBarButtonItem * temp = (UIBarButtonItem *) sender;
        
        if (temp.tag==cancelBarButton){
            NSLog(@"Cancelled");
            [_subView.subviews.lastObject removeFromSuperview];
            UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SubViewController"];
            [vc removeFromParentViewController];
        UIBarButtonItem * returnBtn =
            [[UIBarButtonItem alloc] initWithTitle:@"<回首頁" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView:)];
        [returnBtn setTag:returnBarButton];
        [self.navigationItem setLeftBarButtonItem:returnBtn];
            }
        else if (temp.tag == returnBarButton){
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }
    
}

// NOT REALLY DOING ANYTHING
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentLocation"]){
        currentLocation = _locationMgr.currentLocation;
        NSLog(@"Latitude %+.6f, Longitude %+.6f\n",
              currentLocation.coordinate.latitude,
              currentLocation.coordinate.longitude);
    }
}

#pragma mark - DATABASE METHODS


@end
