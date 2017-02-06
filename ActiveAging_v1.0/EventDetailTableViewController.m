//
//  EventDetailTableViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/23/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventDetailTableViewController.h"
#import "ServerManager.h"
#import "UserInfo.h"
#import "EventDetailSorter.h"
#import "EventManager.h"
#import "EventDetailOuterTableViewCell.h"
#import "EventDetailInnerTableViewCell.h"
#import "ImageManager.h"

@interface EventDetailTableViewController ()<UITableViewDelegate, UITableViewDataSource>{
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    EventManager * _eventManager;
    NSMutableDictionary * newDetailKeyDict;
    NSMutableDictionary * sortedDetailMDict;
    NSMutableArray * sortedDetailMArray;
    
    NSInteger selectedIndex;
    NSString * selectedCategory;
}
@property (weak, nonatomic) IBOutlet UITableView *outerTableView;
@property (weak, nonatomic) IBOutlet UITableView *innerTableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;



@end

@implementation EventDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    _eventManager = [EventManager shareInstance];
    
    
    
    
    
    // SET DELEGATE
    _outerTableView.delegate = self;
    _outerTableView.dataSource = self;
    
//    _outerTableView.estimatedRowHeight = 44;
    _outerTableView.rowHeight = UITableViewAutomaticDimension;
    selectedIndex = -1;
    
    [self setup];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
}

#pragma mark - TABLE_VIEW
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return newDetailKeyDict.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (tableView == _outerTableView){
    EventDetailOuterTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    if (indexPath.row == 0){
//        selectedCategory =
        cell.OuterTopContentTitleLabel.text = newDetailKeyDict.allKeys[indexPath.section];
    }
    else if (indexPath.row == 1 ){
        NSArray * categoryArray = [[NSArray alloc] initWithArray: newDetailKeyDict[selectedCategory]];
        [cell.OuterTopContentTitleLabel setNumberOfLines:0];
        NSString * result = [NSString new];
        for (int i = 0; i<categoryArray.count; i++){
            if ([categoryArray[i] isKindOfClass:[NSString class]]){
                result = [result stringByAppendingString:categoryArray[i]];
            }
            else if ([categoryArray[i] isKindOfClass:[NSNumber class]]){
                result = [result stringByAppendingString:[NSString stringWithFormat:@"%@" ,categoryArray[i]]];
            }
            
            
            result = [result stringByAppendingString:@"\n"];
        }
        cell.OuterTopContentTitleLabel.text = result;
    }
    
        return cell;


}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (selectedIndex == indexPath.row){
//        selectedIndex = -1;
//    } else {
//        selectedIndex = indexPath.row;
//    }
    
    EventDetailOuterTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row== 0 && selectedIndex != indexPath.section){
        selectedIndex = indexPath.section;
        selectedCategory = cell.OuterTopContentTitleLabel.text;
        
    }else{
        selectedIndex = -1;
    }
    
    [tableView reloadData];
    [_outerTableView beginUpdates];
    [_outerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_outerTableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0){
        return 40;
    }
    else if (indexPath.row == 1 && indexPath.section == selectedIndex){
        return 100;
    }
    return 0;
}



- (IBAction)joinBtnPressed:(UIBarButtonItem *)sender {
    // check calendar
    NSString * action;
    
    // add/delete events
    
    if ([sender.title isEqualToString:@"感興趣"]){
        action = USER_EVENT_JOIN;
        
        [_serverMgr retrieveEventInfo:action
                               UserID:_userInfo.getUserID
                              EventID:_eventDetailDict[EVENT_ID_KEY] completion:^(NSError *error, id result) {
                                  NSString * alertTitle, * alertMessage;
                                 
                                  if ([result[ECHO_RESULT_KEY] boolValue]){
                                      alertTitle = @"記錄成功";
                                      alertMessage = @"請與舉辦單位聯繫以完成加入活動手續。";
                                      
                                      [self requestAccessToEventType];
                                      NSDictionary * eventDetail = @{@"startDateTime":_eventDetailDict[EVENT_START_KEY],
                                                                     @"endDateTime": _eventDetailDict[EVENT_END_KEY],
                                                                     @"title": _eventDetailDict[EVENT_TITLE_KEY],
                                                                     @"location": _eventDetailDict[EVENT_ADDRESS_KEY],
                                                                     @"detail": _eventDetailDict[EVENT_DESCRIPTION_KEY]
                                                                     };
                                      [_eventManager newEventToBeAdded:eventDetail complete:^(NSMutableArray *eventArray) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self isNewEventAdded:([eventArray[0] intValue] == 1)?true:false];
                                          });
                                          
                                      }];// EVENT MANAGER
                                      
                                  }
                                  else{
                                      alertTitle = @"失敗";
                                      alertMessage = @"請與開發者聯繫,並敘述發生的問題。";
                                  }
                                  
                                  UIAlertController * alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
                                  UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self returnButtonPressed];
                                      });
                                  }];
                                  [alert addAction:ok];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self presentViewController:alert animated:true completion:nil];
                                  });
                              }];
        
    }else {
        action = USER_EVENT_QUIT;
        [_serverMgr retrieveEventInfo:action
                               UserID:_userInfo.getUserID
                              EventID:_eventDetailDict[EVENT_ID_KEY] completion:^(NSError *error, id result) {
                                  NSString * alertTitle, * alertMessage;
                                  
                                  if ([result[ECHO_RESULT_KEY] boolValue]){
                                      alertTitle = @"成功退出";
                                      alertMessage = @"系統以消除此項目";
                                      
                                      [self requestAccessToEventType];
                                      NSDictionary * eventDetail = @{@"startDateTime":_eventDetailDict[EVENT_START_KEY],
                                                                     @"endDateTime": _eventDetailDict[EVENT_END_KEY],
                                                                     @"title": _eventDetailDict[EVENT_TITLE_KEY],
                                                                     @"location": _eventDetailDict[EVENT_ADDRESS_KEY],
                                                                     @"detail": _eventDetailDict[EVENT_DESCRIPTION_KEY]
                                                                     };
                                      [_eventManager eventToBeRemoved:eventDetail complete:^(NSMutableArray *eventArray) {
                                          if ([eventArray.lastObject boolValue]){
                                              NSLog(@"SUCCESS");
                                          }
                                          else{
                                              NSLog(@"FAILED");
                                          }
                                      }];
                                      
                                  }
                                  else{
                                      alertTitle = @"失敗";
                                      alertMessage = @"請與開發者聯繫,並敘述發生的問題。";
                                  }
                                  
                                  UIAlertController * alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
                                  UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                         [self returnButtonPressed];
                                      });
                                  }];
                                  [alert addAction:ok];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self presentViewController:alert animated:true completion:nil];
                                      
                                  });
                                  
                              }];
        
    }
    
    
    
}

#pragma mark - CALENDAR METHODS
/// MARK: REQUEST_ACCESS_TO_EVENT_TYPE
-(void) requestAccessToEventType {
    [_eventManager requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"無法存取" message:@"「哈啦哈啦趣」無法存取您的行事曆喔，請允許我們使用您的日曆。" preferredStyle:UIAlertControllerStyleAlert];
                
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

/// MARK: CHECK_IF_EVENT_IS_ADDED
-(void) isNewEventAdded: (BOOL) isAdded {
    if (isAdded) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"耶！存好了。" message:@"您可以在月曆上瀏覽新增的活動喔。" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:UIAlertActionStyleDefault];
        
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"哇~沒存到。" message:@"你這段時間已經有活動了唷。" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"好，我知道了。" style:UIAlertActionStyleDefault handler:UIAlertActionStyleDefault];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}



#pragma mark - PRIVATE_METHOD
/// MARK: SETMETHOD
- (void) setup{
    // SETUP THE KEYS
    /*
     pic 圖檔
     organization 舉辦單位
     description  資訊
     registration time 報名期間
     contact info 聯絡方式
     address 地址
     */
    
    // SETUP IMAGE
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    [ImageManager getEventImage:_eventDetailDict[EVENT_PIC_KEY] completion:^(NSError *error, id result) {
        if (!error){
            _imageView.image = [UIImage imageWithData:result];
        }
        else{
            _imageView.image = nil;
        }
    }];
    
    [self.navigationItem setTitle:_eventDetailDict[EVENT_TITLE_KEY]];
    
    NSString * joinButtonName;
    
    if (_eventDetailDict[USER_EVENT_STATUS_KEY]){
        joinButtonName = @"不感興趣";
    } else {
        joinButtonName = @"感興趣";
    }
    
    
    UIBarButtonItem * joinButtonItem = [[UIBarButtonItem alloc] initWithTitle:joinButtonName style:UIBarButtonItemStylePlain target:self action:@selector(joinBtnPressed:)];
    [self.navigationItem setRightBarButtonItem:joinButtonItem];
    
    UIBarButtonItem * returnButton = [[UIBarButtonItem alloc] initWithTitle:@"<回上一頁" style:UIBarButtonItemStylePlain target:self action:@selector(returnButtonPressed)];
    
    [self.navigationItem setLeftBarButtonItem:returnButton];
    
    newDetailKeyDict = [[NSMutableDictionary alloc]
                      initWithDictionary:@{
                                           @"organization":@[EVENT_ORGNTION_KEY, EVENT_WEBPAGE_KEY],
                                           @"description":@[ EVENT_DESCRIPTION_KEY, EVENT_START_KEY, EVENT_END_KEY],
                                           @"registration time": @[EVENT_REG_BEGIN_KEY, EVENT_REG_BEGIN_KEY],
                                           @"contact info":@[EVENT_ORGN_NAME_KEY, EVENT_ORGN_PHONE_KEY, EVENT_ORGN_FAX_KEY,EVENT_ORGN_CELL_KEY, EVENT_ORGN_EMAIL_KEY],
                                           @"address":@[EVENT_CITY_KEY, EVENT_ADDRESS_KEY, EVENT_LON_KEY, EVENT_LAT_KEY]
                                           }];
    
    // sort new dictionary
    [EventDetailSorter returnSortedDictionary:_eventDetailDict BasedDictionary:newDetailKeyDict complete:^(NSMutableDictionary *sortedDictionary) {
        newDetailKeyDict = [[NSMutableDictionary alloc] initWithDictionary:sortedDictionary];
    }];
     
//     returnArrayWithDictionaryFrom:_eventDetailDict KeyDictionary:newDetailKeyDict complete:^(NSMutableArray *sortedArray) {
//        sortedDetailMArray = [[NSMutableArray alloc] initWithArray:sortedArray];
//        [_outerTableView reloadData];
//    }];
    
    
    
    
//    [EventDetailSorter
//     returnSortedDictionary:_eventDetailDict
//     BasedDictionary:basedKeysMDict
//     complete:^(NSMutableDictionary *sortedDictionary) {
//         sortedDetailMDict = [[NSMutableDictionary alloc] initWithDictionary:sortedDictionary];
//         [_outerTableView reloadData];
//         [_innerTableView reloadData];
//     }];
    
    
}


- (void) returnButtonPressed {
//    [self dismissViewControllerAnimated:true completion:nil];
    // Due to SEGUE
    [self.navigationController popViewControllerAnimated:true];
}

-(void)viewDidDisappear:(BOOL)animated{
    NSLog(@"GONE TABLE DETAIL");
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
