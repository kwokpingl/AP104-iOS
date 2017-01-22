//
//  EventDetailViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/22/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventDetailViewController.h"

@interface EventDetailViewController () <UIScrollViewDelegate>
//@property (weak, nonatomic) IBOutlet UIScrollView *detailScrollView;

@end

@implementation EventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIScrollView * _detailScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*2.0/3.0)];
    
    _detailScrollView.pagingEnabled = true;
    _detailScrollView.scrollEnabled = true;
    _detailScrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_detailScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
