//
//  ContactListViewController.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/1.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "ContactListViewController.h"
#import "ServerManager.h"
#import "UserInfo.h"
#import "SQLite3DBManager.h"
#import "ContactTableViewCell.h"

@interface ContactListViewController ()<UITableViewDelegate, UITableViewDataSource>{
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    SQLite3DBManager * _sqlMgr;
    
    NSMutableArray * groupsArray;
    NSMutableArray * contactsArray;
    NSMutableArray * emergencyContactsArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Initiate Singletons
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    _sqlMgr = [[SQLite3DBManager alloc] initWithDatabaseFilename:MOBILE_DATABASE];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // init all Array
    groupsArray = [NSMutableArray new];
    contactsArray = [NSMutableArray new];
    emergencyContactsArray = [NSMutableArray new];
    
    [self updateLists];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TABLEVIEW
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return groupsArray.count;
    } else{
        return contactsArray.count;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSLog(@"Number of Sections");
    if(section == 0)
        return @"群組";
    else
        return @"群組聯絡人";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ContactTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (indexPath.section == 0){
        cell.titleLabel.text = groupsArray[indexPath.row];
        [cell.subtitleLabel setHidden:true];
        [cell.imageView setHidden:true];
    }else{
        cell.titleLabel.text = contactsArray[indexPath.row][USER_NAME_KEY];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if(indexPath.row == 0){
            
        }
    }
}

#pragma mark - BUTTONS
- (IBAction)returnBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - PRIVATE METHOD
- (void) updateLists{
    dispatch_group_t group = dispatch_group_create();
    // user SERVER to UPDATE ALL LISTS
    
    
    
    
    
    // GROUPS
    NSString * query = [NSString stringWithFormat: @"select * from %@",GROUP_LIST_TABLE];
    groupsArray = [@[@"緊急聯絡人"] mutableCopy];
    [groupsArray addObjectsFromArray:[_sqlMgr loadDataFromDB:query]];
    if (groupsArray.count<4){
        [groupsArray addObject:@"新增群組"];
    }
    
    // CONTACTS
    query = [NSString stringWithFormat:@"select * from %@", CONTACT_LIST_TABLE];
    contactsArray = [[_sqlMgr loadDataFromDB:query] mutableCopy];
    [contactsArray addObject:@"新增聯絡人"];
    
    // EMERGENCY GROUP
    query = [NSString stringWithFormat: @"select * from %@",EMERGENCY_TABLE];
    emergencyContactsArray = [[_sqlMgr loadDataFromDB:query] mutableCopy];
    if (emergencyContactsArray.count < 5){
        [emergencyContactsArray addObject:@"新增緊急聯絡人"];
    }
}


@end
