//
//  WelcomeBackViewController.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/24.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "WelcomeBackViewController.h"
#import "HomePageViewController.h"

@interface WelcomeBackViewController ()

@end

@implementation WelcomeBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 100)];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Press ME" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    
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

- (void) buttonPressed: (UIButton *) sender{
    UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

@end
