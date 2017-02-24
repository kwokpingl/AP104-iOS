//
//  HomePageViewController.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/18/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "HomePageViewController.h"
#import "WeatherManager.h"

@interface HomePageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIButton *weatherBtn;

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showClock) userInfo:nil repeats:YES];
    
    //Start
    [[RACObserve([WeatherManager sharedManager], currentCondition)
      
      //2
      //Delivers any changes on the main thread since you’re updating the UI
      deliverOn: RACScheduler.mainThreadScheduler]
     subscribeNext: ^(WeatherCondition * newCondition) {
         
         NSString * temp = [NSString stringWithFormat:@"%.0f°C",newCondition.temperature.floatValue];
         [_weatherBtn setTitle:temp forState:UIControlStateNormal];
         
         UIImage * image = [[UIImage imageNamed:[newCondition imageName]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
         
         [_weatherBtn setImage: image forState:UIControlStateNormal];
         _weatherBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
         _weatherBtn.titleLabel.numberOfLines = 0;
     }];
    
    [[WeatherManager sharedManager] findCurrentLocation];
}

-(void) showClock {
    
    NSDate * now = [NSDate date];
    NSDateFormatter * timeFormatter = [NSDateFormatter new];
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    
#pragma mark - set _timeLabel
    timeFormatter.dateStyle = NSDateFormatterNoStyle;
    timeFormatter.timeStyle = NSDateFormatterShortStyle;
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
//    NSLog(@"%@", [timeFormatter stringFromDate:now]);
    
    _timeLabel.text = [timeFormatter stringFromDate:now];
    
//#pragma mark - set _timeLabel Background Image
//    UIImage * timeBackgroundImage = [UIImage imageNamed:@"HaTime"];
//    CGSize imgSize = _timeLabel.frame.size;
//    UIGraphicsBeginImageContext(imgSize);
//    [timeBackgroundImage drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
//    UIImage * newTimeImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    _timeLabel.backgroundColor = [UIColor colorWithPatternImage:newTimeImage];
    
#pragma mark - set _dateLabel
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
//    NSLog(@"%@", [dateFormatter stringFromDate:now]);
    
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
