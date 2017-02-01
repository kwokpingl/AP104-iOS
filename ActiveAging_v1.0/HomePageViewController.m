//
//  HomePageViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "HomePageViewController.h"

@interface HomePageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showClock) userInfo:nil repeats:YES];
}

-(void) showClock {
    
    NSDate * now = [NSDate date];
    NSDateFormatter * timeFormatter = [NSDateFormatter new];
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    timeFormatter.dateStyle = NSDateFormatterNoStyle;
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    NSLog(@"%@", [timeFormatter stringFromDate:now]);
    
    _timeLabel.text = [timeFormatter stringFromDate:now];
    
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    NSLog(@"%@", [dateFormatter stringFromDate:now]);
    
    _dateLabel.text = [dateFormatter stringFromDate:now];
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
