//
//  EventsViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/22/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventsViewController.h"
#import "EventTableViewCell.h"
#import "ServerManager.h" // retrieveEventInfo



@interface EventsViewController ()<UITableViewDelegate, UITableViewDataSource>{
    
    NSDictionary * eventsDict;
    ServerManager * _serverMgr;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *eventRecordButton;
@end

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    eventsDict = [NSMutableDictionary new];
    _serverMgr = [ServerManager shareInstance];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    // start loading the data
//    _serverMgr retrieveEventInfo:USER_EVENT_FETCH UserID:<#(NSString *)#> EventID:<#(NSString *)#> completion:<#^(NSError *error, id result)done#>
    
    // then reload Table
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}
- (IBAction)locationButtonPressed:(id)sender {
}

- (IBAction)recordButtonPressed:(id)sender {
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
