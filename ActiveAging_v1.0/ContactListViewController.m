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
#import "EmergencyViewController.h"

#import "ServerManager.h"
#import "UserInfo.h"
#import "DataManager.h"
#import "ImageManager.h"
#import "EmergencyButton.h"

#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

typedef enum {
    alertAddMember,
    alertAddEmergency,
    alertCreateGroup,
    alertQuitGroup,
    alertAccessGroup,
    alertAccessOtherGroup,
    alertMemberDetail
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

typedef enum {
    showingGroups,
    showingMembers
}tableViewInfo;

@interface ContactListViewController ()<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, CNContactViewControllerDelegate, CNContactPickerDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate>
{
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    
    // LISTS
    NSMutableArray * contactList;
    NSMutableArray * personalGroupList;
    NSMutableArray * otherGroupList;
    NSMutableArray * emergencyList;
    NSMutableArray * targetList;
    
    NSArray * pickerViewArray;
    NSString * targetKey;
    
    // Trackers
    NSInteger emergencyMemberNumber;
    NSInteger role;
    NSInteger currentGroup;
    NSInteger currentTableInfo;
    NSInteger selectedGroupId;
    NSInteger selectedSection;
    NSInteger selectedMemberID;
    
    // CONTACT LIST
    CNContactStore * storeManager;
    NSMutableArray * contactsSelected;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIPickerView * pickerView;
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (strong, nonatomic) EmergencyButton *emergencyButton;
@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog(@"TestViewController Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef) self));
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    
    // Initiate Singletons
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    storeManager = [CNContactStore new];
    
    [DataManager prepareDatabase];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
//    _tableView.tableFooterView = [UITableViewHeaderFooterView new];
//    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    pickerViewArray = @[@"請選群組",@"個人群組",@"其他群組",@"緊急聯絡人"];
    
    _emergencyButton = [EmergencyButton new];
    [_emergencyButton addTarget:self action:@selector(callEmergency) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_emergencyButton];
    
    currentGroup = -1;
    
    [self reloadGroupList]; // UPDATE THE DATABASE
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_pickerView selectRow:0 inComponent:0 animated:true];
        [self pickerView:_pickerView didSelectRow:0 inComponent:0];
    });
}


#pragma mark - === TABLEVIEW ===
/// MARK: SETUPs
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    _tableView.contentInset = UIEdgeInsetsZero;
    return targetList.count;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.0;
}

/// MARK: TABLEVIEWCELL
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.imageView setHidden:true];
    
    if (currentTableInfo == showingGroups){
        [cell.titleLabel setText:targetList[indexPath.section][targetKey] ];
        
        if (targetList[indexPath.section][GROUP_ID_KEY] == nil){
            [cell.imageView setImage:[ImageManager loadImageWithFileName:targetList[indexPath.section][USER_PIC_KEY]]];
            
            [cell.imageView setHidden:false];
        }
        
        if ([targetList[indexPath.section][USER_ROLE_KEY] integerValue] == -2){
            [cell.imageView setImage:[UIImage imageNamed:@"Undetermined"]];
            [cell.imageView setHidden:false];
        }
    }
    
    // IF I CHOOSE FROM TABLE
    else if (currentTableInfo == showingMembers){
        targetKey = USER_NAME_KEY;
        cell.titleLabel.text = targetList[indexPath.section][targetKey];
        NSInteger userID = [targetList[indexPath.section][USER_ID_KEY] integerValue];
        NSInteger memberRole = [targetList[indexPath.section][USER_ROLE_KEY] integerValue];
        
        
        if (currentGroup == emergencyGroup){
            if ([targetList[indexPath.section][USER_ID_KEY] integerValue]!=-3){
                [cell.imageView setHidden:false];
                [cell.imageView setImage:[ImageManager loadImageWithFileName:targetList[indexPath.section][USER_PIC_KEY]]];
            }
        }
        else {
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
            }
            if (memberRole == -2){
                
                [cell.imageView setImage:[UIImage imageNamed:@"Undetermined"]];
                
            }
            
            
        }
    }
    
    return cell;
}

/// MARK: SELECT_TABLE_CELL
-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (currentTableInfo == showingGroups){
        // Select GROUPS
        if ([targetList[indexPath.section][GROUP_ID_KEY] integerValue] == -2){
            [self showAlert:alertCreateGroup];
        }
        else if ([targetList[indexPath.section][GROUP_ID_KEY] integerValue] == -3){
            [self showAlert:alertAddEmergency];
        }
        else{
            selectedGroupId = [targetList[indexPath.section][GROUP_ID_KEY] integerValue];
            selectedSection = indexPath.section;
            role = [targetList[selectedSection][USER_ROLE_KEY] integerValue];
            [self showAlert:alertAccessGroup];
        }
    }
    
    if (currentTableInfo == showingMembers){
        // Select MEMBER
        selectedMemberID = [targetList[indexPath.section][USER_ID_KEY] integerValue];
        selectedSection = indexPath.section;
        switch (currentGroup) {
            case personalGroup:
                if (selectedMemberID == -3){
                    [self showAlert:alertAddMember];
                }
                else {
                    [self showAlert:alertMemberDetail];
                }
                break;
            case otherGroup:
                [self showAlert:alertMemberDetail];
                break;
            case emergencyGroup:
                if (selectedMemberID == -3){
                    [self showAlert:alertAddEmergency];
                }
                else {
                    [self showAlert:alertMemberDetail];
                }
                break;
            default:
                break;
        }
    }
  
    NSLog(@"LAYER: %ld", currentTableInfo);
    
    [_tableView reloadData];
}


#pragma mark - === PICKER_VIEW ===
/// MARK: SETUP_PICKERVIEW
-(NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
    return pickerViewArray.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView
rowHeightForComponent:(NSInteger)component{
    return 60;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view{
    
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
-(void)pickerView:(UIPickerView *)pickerView
     didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self getGroup:row-1];
    [_tableView reloadData];
}




#pragma mark - === ALERTS for EDIT CONTACTS/GROUPS ===
- (void) showAlert: (NSInteger) alertType{
    
    UIAlertController * alert;
    NSString * alertTitle;
    NSString * alertMessage;
    UIAlertControllerStyle alertStyle;
    
    UIAlertAction * ok;
    NSString * okTitle;
    
    UIAlertAction * cancel;
    NSString * cancelTitle;
    
    
    switch (alertType) {
            /// MARK: CREATE_GROUP
        case alertCreateGroup:
        {
            if (personalGroupList.count >= 3){
                
                alertStyle = UIAlertControllerStyleActionSheet;
                alertTitle = @"發生錯誤";
                alertMessage = @"很抱歉，目前您的群組數量已達極限 (3組)。\n請升級後再增加群組。";
                okTitle = @"確定";
                
                alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage
                                                     preferredStyle:alertStyle];
                ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:nil];
                
                [alert addAction:ok];
            }
            else {
                alertStyle = UIAlertControllerStyleAlert;
                alertTitle = @"新增群組";
                alertMessage = @"請輸入群組名稱";
                okTitle = @"新增";
                cancelTitle = @"取消";
                
                alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:alertStyle];
                cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
                ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // CHECK INPUT
                    NSString * groupName = alert.textFields.lastObject.text;
                    
                    if (![groupName isEqualToString:@""]){
                        if ([self check:GROUP_NAME_KEY withString:groupName]){
                            // ADD GROUP
                            NSString * finalStr = [alert.textFields.lastObject.text
                                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            NSDictionary * data = @{USER_ID_KEY: @(_userInfo.getUserID),
                                                    GROUP_NAME_KEY: finalStr};
                            
                            /// MARK: CREATE_GROUP
                            [_serverMgr updateUserGroupsWithAction:GROUP_ACTION_CREATE dataInfo:data completion:^(NSError *error, id result) {
                                NSString * message;
                                NSString * title;
                                
                                if(error){
                                    title = @"發生錯誤";
                                    message = error.description;
                                }
                                else
                                {
                                    if ([result[ECHO_RESULT_KEY] boolValue]){
                                        title = @"訊息";
                                        message = @"成功建立群組";
                                    }
                                    else{
                                        title = @"發生錯誤";
                                        message = result[ECHO_ERROR_KEY];
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self updateReturnAlertWithTitle:title andMessage:message];
                                });
                            }];
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self showNamingFailedAlert];
                            });
                        }
                    }
                }];

                
                [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    [textField setPlaceholder:@"群組名稱"];
                    [textField setFont:[UIFont systemFontOfSize:25.0]];
                    [textField setAdjustsFontSizeToFitWidth:true];
                }];
                [alert addAction:ok];
                [alert addAction:cancel];
            }
            
            
            [self presentViewController:alert
                               animated:true
                             completion:nil];
        }
            break;
            
            
        /// MARK: QUIT_GROUP
        case alertQuitGroup:
        {
            alertTitle = @"警告";
            alertMessage = @"請問您確定要退出/刪除此群組嗎?";
            alertStyle = UIAlertControllerStyleActionSheet;
            okTitle = @"確定";
            cancelTitle = @"取消";
            alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:alertMessage
                                                 preferredStyle:alertStyle];
            cancel = [UIAlertAction actionWithTitle:cancelTitle
                                              style:UIAlertActionStyleCancel
                                            handler:nil];
            
            ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
            {
                [self quitGroupAlert];}];
            
            
            [alert addAction:ok];
            [alert addAction:cancel];
            [self presentViewController:alert animated:true completion:nil];
        }
            break;
            
        /// MARK: ADD_MEMBER
        case alertAddMember:
        {
            alertStyle = UIAlertControllerStyleAlert;
            alertTitle = @"新增組員";
            alertMessage = @"請輸入組員電話";
            okTitle = @"確定";
            cancelTitle = @"取消";
            
            alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:alertMessage
                                                 preferredStyle:alertStyle];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                [textField setKeyboardType:UIKeyboardTypePhonePad];
                [textField setFont:[UIFont systemFontOfSize:25.0]];
                [textField setAdjustsFontSizeToFitWidth:true];
                [textField setPlaceholder:@"組員電話"];
                [textField setDelegate:self];
            }];
            cancel = [UIAlertAction actionWithTitle:cancelTitle
                                              style:UIAlertActionStyleCancel
                                            handler:nil];
            ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSString * phoneNumber = alert.textFields.lastObject.text;
                
                if (![phoneNumber isEqualToString:@""] && ![phoneNumber isEqualToString:[UserInfo shareInstance].getPassword]){
                    if ([self check:USER_PHONENUMBER_KEY withString:alert.textFields.lastObject.text]){
                        [_serverMgr sendInvitationFor:alert.textFields.lastObject.text ToGroupID:selectedGroupId withAction:GROUP_ACTION_ADDMEMBER completion:^(NSError *error, id result) {
                           if (error){
                               NSLog(@"ERROR : %@", error);
                           }
                           else{
                               if ([result[ECHO_RESULT_KEY] boolValue]){
                                   NSString * message = @"成功邀請對方";
                                   [self showMessageAlert:message success:true];
                                   [_tableView reloadData];
                               }
                               else
                               {
                                   [self sendSMS:phoneNumber];
                               }
                           }
                        }];
                    }
                    
                }
                else {
                    // GIVE ALERT
                    UIAlertController * innerAlert = [UIAlertController alertControllerWithTitle:@"發生錯誤" message:@"電話輸入有誤" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * innerOk = [UIAlertAction actionWithTitle:@"瞭解" style:UIAlertActionStyleDefault handler:nil];
                    [innerAlert addAction:innerOk];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:innerAlert animated:true completion:nil];
                    });
                }
            }];
            cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            
            [alert addAction:ok];
            [alert addAction:cancel];
            [self presentViewController:alert animated:true completion:nil];
        }
            break;
            
        /// MARK: ADD_EMERGENCY
        case alertAddEmergency:
        {
            [self requestAcessToEntityType];
        }
            break;
        /// MARK: ACCESS_GROUP
        case alertAccessGroup:
        {
            alertTitle = @"選項";
            alertStyle = UIAlertControllerStyleActionSheet;
            cancelTitle = @"取消";
            
            alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:alertStyle];
            cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
            
            
            /// MARK: PERSONAL GROUP
            if (currentGroup == personalGroup){
                // allow users to EDIT, RENAME, and DELETE group
                /// MARK:: SHOW DETAIL
                UIAlertAction * showDetail = [UIAlertAction actionWithTitle:@"編輯群組" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self getContact:selectedSection];
                }];
                
                /// MARK:: CHANGE NAME
                UIAlertAction * changeName = [UIAlertAction actionWithTitle:@"修改組名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    UIAlertController * renameController = [UIAlertController alertControllerWithTitle:@"請輸組名" message:@"請輸入您的新組名" preferredStyle:UIAlertControllerStyleAlert];
                    
                    [renameController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        [textField setPlaceholder:@"群組名字"];
                        [textField setFont:[UIFont systemFontOfSize:25.0]];
                        [textField setAdjustsFontSizeToFitWidth:true];
                    }];
                    
                    UIAlertAction * rename = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        NSString * newName = renameController.textFields.lastObject.text;
                        if ([self check:GROUP_NAME_KEY withString:newName])
                        {
                            NSDictionary * data = @{USER_ID_KEY:@(_userInfo.getUserID),
                                                    GROUP_ID_KEY:@(selectedGroupId),
                                                    GROUP_NAME_KEY: newName};
                            
                            [_serverMgr updateUserGroupsWithAction:GROUP_ACTION_UPDATENAME dataInfo:data completion:^(NSError *error, id result) {
                                NSString * message;
                                BOOL success;
                                
                                if(error){
                                    message = error.description;
                                    success = false;
                                }
                                else{
                                    success = [result[ECHO_RESULT_KEY] boolValue];
                                    
                                    if (success){
                                        message = @"成功改名";
                                    }
                                    else{
                                        message = result[ECHO_ERROR_KEY];
                                    }
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self showMessageAlert:message success:success];
                                });
                            }];
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self showNamingFailedAlert];
                            });
                        }
                    }]; // END OF RENAME
                    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    [renameController addAction:rename];
                    [renameController addAction:cancel];
                    [self presentViewController:renameController
                                       animated:true
                                     completion:nil];
                    
                }]; // CHANGE NAME ACTION
                
                /// MARK:: DELETE GROUP
                UIAlertAction * deleteGroup = [UIAlertAction actionWithTitle:@"刪除群組" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self showAlert:alertQuitGroup];
                    
                }]; // DELETE ACTION
                
                [alert addAction:showDetail];
                [alert addAction:changeName];
                [alert addAction:deleteGroup];
                
            }
            else {
                // allow users to ACCESS and QUIT group
                // if role == -2, then allow users to JOIN/QUIT group
                
                /// MARK: OTHER GROUP
                if (role == -2){
                    /// MARK:: JOIN
                    UIAlertAction * join = [UIAlertAction actionWithTitle:@"加入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                       // update role
                        
                        NSDictionary * data = @{USER_ID_KEY: @(_userInfo.getUserID),
                                                GROUP_ID_KEY: targetList[selectedSection][GROUP_ID_KEY]};
                        
                        [_serverMgr updateUserGroupsWithAction:GROUP_ACTION_UPDATEROLE dataInfo:data completion:^(NSError *error, id result) {
                            NSString * message;
                            BOOL success;
                            
                            if (error){
                                success = false;
                                message = error.description;
                            }
                            else{
                                success = [result[ECHO_RESULT_KEY] boolValue];
                                
                                if(success){
                                    message = @"成功加入";
                                    [self changeBadgeNumber:-1];
                                }
                                else{
                                    message = result[ECHO_MESSAGE_KEY];
                                }
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self showMessageAlert:message success:success];
                            });
                            
                        }];
                    }];
                    
                    /// MARK:: UNJOIN
                    UIAlertAction * unjoin = [UIAlertAction actionWithTitle:@"不加入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        NSDictionary * data = @{USER_ID_KEY: @(_userInfo.getUserID),
                                                GROUP_ID_KEY: targetList[selectedSection][GROUP_ID_KEY]};
                        
                        [_serverMgr updateUserGroupsWithAction:GROUP_ACTION_DROP dataInfo:data completion:^(NSError *error, id result) {
                            
                            NSString * message;
                            BOOL success;
                            
                            if(error){
                                message = error.description;
                                success = false;
                            }
                            else{
                                success = [result[ECHO_RESULT_KEY] boolValue];
                                if(success){
                                    message = @"成功退出";
                                    [self changeBadgeNumber:-1];
                                }
                                else{
                                    message = result[ECHO_MESSAGE_KEY];
                                }
                                
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self showMessageAlert:message success:success];
                            });
                        }];
                    }];
                    
                    [alert addAction: join];
                    [alert addAction: unjoin];
                    
                }
                else{
                    /// MARK:: ACCESS
                    UIAlertAction * access = [UIAlertAction actionWithTitle:@"查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self getContact:selectedSection];
                    }];
                    
                    /// MARK:: QUIT
                    UIAlertAction * quit = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [self showAlert:alertQuitGroup];
                    }];
                    
                    [alert addAction:access];
                    [alert addAction:quit];
                }
            }
            
            [alert addAction:cancel];
            [self presentViewController:alert animated:true completion:nil];
        }
            break;
        /// MARK: MEMBER DETAIL
        case alertMemberDetail:
        {
            NSString * showCallTitle = @"撥打電話";
            NSString * deleteTitle = @"刪除組員";
            alertTitle = @"請選擇";
            cancelTitle = @"取消";
            
            alertStyle = UIAlertControllerStyleActionSheet;
            
            alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                        message:@""
                                                 preferredStyle:alertStyle];
            cancel = [UIAlertAction actionWithTitle:cancelTitle
                                              style:UIAlertActionStyleCancel
                                            handler:nil];
            UIAlertAction * callBtn = [UIAlertAction actionWithTitle:showCallTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self callNumber];
            }];
            
            UIAlertAction * deleteBtn = [UIAlertAction actionWithTitle:deleteTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                switch (currentGroup) {
                    case personalGroup:
                    {
                        NSDictionary * data = @{USER_ID_KEY: @(_userInfo.getUserID),
                                                GROUP_ID_KEY: targetList[selectedSection][GROUP_ID_KEY],
                                                GROUP_MEMBER_KEY: targetList[selectedSection][USER_ID_KEY]};
                        [_serverMgr updateUserGroupsWithAction:GROUP_ACTION_DROPMEMBER dataInfo:data completion:^(NSError *error, id result) {
                            BOOL success = false;
                            if (error){
                                [self showMessageAlert:error.description success:success];
                            }
                            else{
                                
                                success = [result[ECHO_RESULT_KEY] boolValue];
                                if (success){
                                    [self showMessageAlert:@"成功刪除組員" success:success];
                                }
                                else{
                                    [self showMessageAlert:result[ECHO_ERROR_KEY] success:success];
                                }
                            }
                        }];
                    }
                        break;
                    case emergencyGroup:
                    {
                        [DataManager updateEmergencyDatabaseWithAction:ACTION_DELETE andDataDic:@{USER_ID_KEY: targetList[selectedSection][USER_ID_KEY]}];
                        [self reloadGroupList];
                    }
                        break;
                    default:
                        break;
                }
                
                
            }];
            
            switch (currentGroup) {
                case emergencyGroup:
                case personalGroup:
                    if ([targetList[selectedSection][USER_ROLE_KEY] integerValue] == -2){
                        [alert addAction:deleteBtn];
                        [alert addAction:cancel];
                    }
                    else{
                        [alert addAction:callBtn];
                        [alert addAction:deleteBtn];
                        [alert addAction:cancel];
                    }
                    break;
                case otherGroup:
                    [alert addAction:callBtn];
                    [alert addAction:cancel];
                    break;
                default:
                    break;
            }
            
            [self presentViewController:alert animated:true completion:nil];
        }
            break;
        default:
            break;
    }
    
    
    
}



#pragma mark - === Request Access for CONTACT LIST ===
- (void) requestAcessToEntityType {
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    if ( status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted || status == CNAuthorizationStatusNotDetermined){
        [storeManager requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"%@", error);
                return;
            }
            
            if (!granted) {
                
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"無法存取" message:@"「哈啦哈啦趣」無法讀取您的電話簿。" preferredStyle: UIAlertControllerStyleAlert];
                UIAlertAction * ok = [UIAlertAction actionWithTitle:@"瞭解" style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction * redirect = [UIAlertAction actionWithTitle:@"設定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [alert addAction:ok];
                [alert addAction:redirect];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alert animated:YES completion:nil];
                });
                return;
            } //end of if (!granted)
            else {
                [self openContactList];
            }
        }];
    }
    else if (status == CNAuthorizationStatusAuthorized){
        [self openContactList];
    }
    
}

#pragma mark - ===CNContactPickerViewController===
- (void) openContactList {
    CNContactPickerViewController * picker = [CNContactPickerViewController new];
    picker.delegate = self;
    picker.title = @"聯絡人清單";
    picker.predicateForSelectionOfContact = [NSPredicate predicateWithValue:true];
    
    picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey,
                                     CNContactGivenNameKey,
                                     CNContactFamilyNameKey,
                                     CNContactImageDataKey];
    
    picker.predicateForSelectionOfProperty = [NSPredicate predicateWithFormat:@"(key == 'phoneNumber') OR (key == 'givenName') OR (key == 'familyName')"];
    
    picker.predicateForSelectionOfProperty = [NSPredicate predicateWithValue:true];
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(contactPicker:didSelectContacts:)];
    UIBarButtonItem * left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(contactPickerDidCancel:)];
    [picker.navigationItem setRightBarButtonItem:right];
    [picker.navigationItem setLeftBarButtonItem:left];
    
    
    [self presentViewController:picker animated:true completion:nil];
}

- (void) contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {
    
    contactsSelected = [NSMutableArray new];
    NSString * phoneNumberStr;
    NSString * identifier;
    NSData * imageData;
    NSString * userName;
    NSString * imageName;
    
    for (CNContact * c in contacts) {
        
        /// MARK: GET_UserName
        userName = [NSString stringWithFormat:@"%@ %@ %@",
                    c.givenName, c.middleName, c.familyName];
        
        /// MARK: CHECK_PhoneNumber
        if (!c.phoneNumbers.count)
        {
            phoneNumberStr = @"無資料";
        }
        else
        {
            for (int i = 0; i < c.phoneNumbers.count; i++){
                
                CNLabeledValue * labelValue = c.phoneNumbers[i];
                
                // Use Main phone number as the First choice
                if ([labelValue.label isEqualToString:CNLabelPhoneNumberMain]){
                    CNPhoneNumber * phoneNumber = labelValue.value;
                    phoneNumberStr = [NSString stringWithFormat: @"%@", phoneNumber.stringValue];
                    break;
                }
                else{
                    CNPhoneNumber * phoneNumber = labelValue.value;
                    
                    // user moblie phone number as Second choice
                    if ([labelValue.label isEqualToString:CNLabelPhoneNumberMobile]){
                        phoneNumberStr = [NSString stringWithFormat: @"%@", phoneNumber.stringValue];
                    }
                    // just grab whatever available
                    else if (phoneNumberStr == nil){
                        phoneNumberStr = [NSString stringWithFormat: @"%@", phoneNumber.stringValue];
                    }
                }
            }
        }
        
        if (c.imageDataAvailable) {
            imageData = c.imageData;
        } else {
            imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"ha1"], 1);
        }
        
        
        if (!c.identifier){
            identifier = @"無資料";
        }
        else{
            identifier = c.identifier;
        }
        
        NSDictionary * dic;
        imageName = [identifier stringByAppendingPathExtension:@"jpg"];
        [ImageManager saveImageWithFileName:imageName ImageData:imageData];
        
        dic = [@{USER_ID_KEY: identifier, USER_NAME_KEY: userName, USER_PHONENUMBER_KEY: phoneNumberStr,USER_PIC_KEY: imageName} mutableCopy];
        
        // Save them in Database as well
        [DataManager updateEmergencyDatabaseWithAction:ACTION_ADD andDataDic:dic];
    }
    
    [self reloadGroupList];
    [self getGroup:emergencyGroup];
    [_tableView reloadData];
}



#pragma mark - ===SHOW Sub-Alerts===
/// MARK: FAILED NAMING ALERT
- (void) showNamingFailedAlert {
    UIAlertController * innerAlert = [UIAlertController alertControllerWithTitle:@"發生錯誤" message:@"請勿輸入符號" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * innerOk = [UIAlertAction actionWithTitle:@"瞭解" style:UIAlertActionStyleDefault handler:nil];
    [innerAlert addAction:innerOk];
    [self presentViewController:innerAlert animated:true completion:nil];
}

/// MARK: SHOW MESSAGE ALERT
- (void) showMessageAlert: (NSString *) message success:(BOOL) isSuccess {
    
    NSString * title = @"發生錯誤";
    if (isSuccess){
        title = @"成功";
    }
    
    UIAlertController * innerAlert = [UIAlertController alertControllerWithTitle:title message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * innerOk = [UIAlertAction actionWithTitle:@"瞭解" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadGroupList];
        });
    }];
    [innerAlert addAction:innerOk];
    [self presentViewController:innerAlert animated:true completion:nil];
}

/// MARK: UPDATE ALERT
- (void) updateReturnAlertWithTitle: (NSString *) title
                         andMessage: (NSString *) message{
    UIAlertController * resultAlert = [UIAlertController alertControllerWithTitle: title message:message
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self reloadGroupList];
    }];
    [resultAlert addAction:ok];
    [self presentViewController:resultAlert animated:true completion:nil];
}

/// MARK: QUIT GROUP ALERT
- (void) quitGroupAlert {
    NSDictionary * data = @{USER_ID_KEY:@(_userInfo.getUserID),
                            GROUP_ID_KEY:@(selectedGroupId)};
    
    [_serverMgr updateUserGroupsWithAction:GROUP_ACTION_DROP dataInfo:data completion:^(NSError *error, id result) {
        
        NSString * title;
        NSString * message;
        
        if (error){
            title = @"發生錯誤";
            message = error.description;
        }
        else {
            if ([result[ECHO_RESULT_KEY] boolValue]){
                title = @"成功";
                message = @"您已退出/刪除此群組";
            }
            else{
                title = @"發生錯誤";
                message = result[ECHO_MESSAGE_KEY];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateReturnAlertWithTitle:title
                                  andMessage:message];
        });
        
        
    }];
    
    [self reloadGroupList];
}


#pragma mark - === PRIVATE METHOD ===
///MARK: RELOAD_ALL_LIST
- (void) reloadGroupList{
    [DataManager prepareDatabase];
    [DataManager updateContactDatabase:^(BOOL done) {
        if (done){
            personalGroupList = [[NSMutableArray alloc] initWithArray:[DataManager fetchGroupsFromTableWithRole:1]];
            otherGroupList = [[NSMutableArray alloc] initWithArray:[DataManager fetchGroupsFromTableWithRole:-2]];
            [otherGroupList addObjectsFromArray:[DataManager fetchGroupsFromTableWithRole:-1]];
            emergencyList = [[NSMutableArray alloc] initWithArray:[DataManager fetchDatabaseFromTable:EMERGENCY_TABLE]];
            contactList = [NSMutableArray new];
            contactList = [DataManager fetchDatabaseFromTable:CONTACT_LIST_TABLE];
            [self getGroup:currentGroup];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
    }];
    
}

///MARK: GET_GROUP_LIST
- (void) getGroup: (NSInteger) group {
    targetList = [NSMutableArray new];
    currentTableInfo = 0;
    switch (group) {
        case personalGroup:
        {
            targetKey = GROUP_NAME_KEY;
            currentGroup = personalGroup;
            currentTableInfo = showingGroups;
            
            [targetList addObjectsFromArray: personalGroupList];
            
            NSString * message;
            
            if (targetList.count <3){
                message = [NSString stringWithFormat:@"+ 尚可新增 %ld 群組", MAXIMUM_PERSONAL_GROUP - targetList.count];
            }
            else
            {
                message = @"升級";
            }
            [targetList addObject:@{GROUP_ID_KEY:@(-2), targetKey:message, USER_ROLE_KEY:@(0)}];
        }
            break;
            
        case otherGroup:
            
            targetKey = GROUP_NAME_KEY;
            currentGroup = otherGroup;
            currentTableInfo = showingGroups;
            
            [targetList addObjectsFromArray: otherGroupList];
            break;
            
        case emergencyGroup:
            
            targetKey = USER_NAME_KEY;
            currentGroup = emergencyGroup;
            currentTableInfo = showingMembers;
            
            [targetList addObjectsFromArray: emergencyList];
            
            emergencyMemberNumber = targetList.count;
            
            if(targetList.count <5){
                NSString * message = [NSString stringWithFormat:@"+ 尚可新增 %ld 聯絡人", MAXIMUM_EMERGENCY_GROUP - targetList.count];
                [targetList addObject:@{USER_ID_KEY:@(-3), targetKey:message}];
            }
            break;
            
        default:
            currentGroup = group;
            targetList = nil;
            break;
    }
}

///MARK: GET_CONTACT_A_GROUP
- (void) getContact: (NSInteger) groupRow{
    
    NSInteger groupID = [targetList[groupRow][GROUP_ID_KEY] integerValue];
    NSString * groupName = targetList[groupRow][GROUP_NAME_KEY];
    role = [targetList[groupRow][USER_ROLE_KEY] integerValue];
    
    currentTableInfo = showingMembers;
    targetList = [NSMutableArray new];
    
    
    // Set the Title of Navigation to be the GroupName
    [self.navigationItem setTitle:groupName];
    [targetList addObjectsFromArray:[DataManager fetchUserInfoFromTableWithGroupID:groupID]];
    
    if (role == 1 && targetList.count < MAXIMUM_MEMBER_PER_GROUP )
    {
        [targetList addObject:@{USER_ID_KEY:@(-3), USER_NAME_KEY:@"+ 新增組員"}];
    }
    
    [_tableView reloadData];
}

/// MARK: CHECK PREDICATE
- (BOOL) check: (NSString *) type withString: (NSString *) str {
    
    NSPredicate * predicate;
    BOOL match;
    
    if ([str isEqualToString:@""])
    {
        match = false;
    }
    else
    {
        if ([type isEqualToString:USER_PHONENUMBER_KEY])
        {
            predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHONE_NUMBER_REX];
        }
        else if ([type isEqualToString:GROUP_NAME_KEY])
        {
            predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", GROUP_NAME_REX];
        }
        
        match = [predicate evaluateWithObject:str];
    }
    
    return match;
}


/// MARK: Alternate Badge Number
- (void) changeBadgeNumber: (NSInteger) adjustNumber {
    NSInteger badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber+adjustNumber];
}

- (void) endEditing:(id) sender{
    [self.view endEditing:true];
}


- (void)dealloc {
    NSLog(@"TestViewController Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef) self));
}

- (void) callEmergency {
    [_emergencyButton callNumbers:self.navigationController];
}


#pragma TEXT FIELD DELEGATE
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * newString = [textField.text
                            stringByReplacingCharactersInRange:range
                            withString:string];
    return !([newString length]>PHONE_NUMBER_LENGTH);
    
}

#pragma mark - CALLING
- (void) callNumber{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    NSString *code = [networkInfo.subscriberCellularProvider mobileCountryCode];
    
    //this is nil if you take out sim card.
    if (code == nil) {
        
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"錯誤訊息" message:@"沒發現 Sim 卡" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    
            [alertView addAction:cancel];
        [self presentViewController:alertView animated:true completion:nil];
        
        
        return;
    }
    
    // iOS 8 tel: does the same as telpromt://
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", targetList[selectedSection][USER_PHONENUMBER_KEY]]];
    NSLog(@"NSURL url = %@", url);
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - SEND SMS
- (void) sendSMS:(NSString *) number{
    if([MFMessageComposeViewController canSendText]){
        MFMessageComposeViewController * controller = [MFMessageComposeViewController new];
        NSString * body = [NSString stringWithFormat:@"%@想邀請您加入「哈啦哈啦趣」喔",[UserInfo shareInstance].getUsername];
        controller.body = body;
        controller.recipients = [NSArray arrayWithObject:number];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:true completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:true completion:nil];
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
            [self showMessageAlert:@"傳送成功" success:true];
            break;
        case MessageComposeResultFailed:
            [self showMessageAlert:@"傳送失敗" success:false];
            break;
        default:
            break;
    }
}

@end
