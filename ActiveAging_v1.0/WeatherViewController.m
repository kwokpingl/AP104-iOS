//
//  WeatherViewController.m
//  Weather
//
//  Created by Ga Wai Lau on 1/25/17.
//  Copyright © 2017 SAL. All rights reserved.
//

#import "WeatherViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WeatherManager.h"

@interface WeatherViewController () <CLLocationManagerDelegate> {
    CLLocationManager * locationManager;
}

@property (nonatomic, strong) UIImageView * backgrounImageView;
@property (nonatomic, strong) UIImageView * blurredImageView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, strong) NSDateFormatter * hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter * dailyFormatter;

@end

@implementation WeatherViewController

// NSDateFormatter objects are expensive to initialize, but by placing them in -init you’ll ensure they’re initialized only once by your view controller
-(id) init {
    if (self = [super init]) {
        NSLocale * twLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
        
        _hourlyFormatter = [NSDateFormatter new];
        _hourlyFormatter.dateFormat = @"h a";
        _hourlyFormatter.locale = twLocale;
        
        _dailyFormatter = [NSDateFormatter new];
        _dailyFormatter.dateFormat =@"EEEE";
        _dailyFormatter.locale = twLocale;
    }
    return self;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];*/
    
#pragma mark - set up Image View & table View
    //1
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage * background = [UIImage imageNamed:@"bg"];
    
    //2
    self.backgrounImageView = [[UIImageView alloc] initWithImage:background];
    self.backgrounImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgrounImageView];
    
    //3
    self.blurredImageView = [UIImageView new];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    //4
    self.tableView = [UITableView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
#pragma mark - set up frames and margins
    //Set up layout frames and margins
    //1
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    //2
    CGFloat inset = 20;
    //3
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    //4
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    //5
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
#pragma mark - set up labels
    //1
    UIView * header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    //2 - bottom left
    UILabel * temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°C";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    UILabel * hiloLabel = [[UILabel alloc] initWithFrame: hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    // top
//    UILabel * cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
//    cityLabel.backgroundColor = [UIColor clearColor];
//    cityLabel.textColor = [UIColor whiteColor];
//    cityLabel.text = @"Loading";
//    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
//    cityLabel.textAlignment = NSTextAlignmentCenter;
//    [header addSubview:cityLabel];
    
    UILabel * conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:45];
    conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview: conditionsLabel];
    
    //3 - bottom left
    UIImageView * iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
    
#pragma mark - Observe the current Condition
    //1
    //Observes the currentCondition key on the WeatherManager singleton
    [[RACObserve([WeatherManager sharedManager], currentCondition)
      
      //2
      //Delivers any changes on the main thread since you’re updating the UI
     deliverOn: RACScheduler.mainThreadScheduler]
     subscribeNext: ^(WeatherCondition * newCondition) {
         
         // 3
         //Updates the text labels with weather data; you’re using newCondition for the text and not the singleton. The subscriber parameter is guaranteed to be the new value
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         conditionsLabel.text = [newCondition.condition capitalizedString];
//         cityLabel.text = [newCondition.locationName capitalizedString];
         
         // 4
         //Uses the mapped image file name to create an image and sets it as the icon for the view
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    
#pragma mark - ReactiveCocoa Bindings
    //1
    //The RAC(…) macro helps keep syntax clean. The returned value from the signal is assigned to the text key of the hiloLabel object
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       
                                                      //2
                                                       //Observe the high and low temperatures of the currentCondition key. Combine the signals and use the latest values for both. The signal fires when either key changes
                                                      RACObserve([WeatherManager sharedManager], currentCondition.tempHigh),
                                                      RACObserve([WeatherManager sharedManager], currentCondition.tempLow)]
                             
                            //3
                             //Reduce the values from your combined signals into a single value; note that the parameter order matches the order of your signals
                                             reduce:^(NSNumber * hi, NSNumber * low) {
                                                 return [NSString stringWithFormat:@"%.0f°C / %.0f°C", hi.floatValue, low.floatValue];
                                             }]
    //4
    deliverOn:RACScheduler.mainThreadScheduler];
    //The code above binds high and low temperature values to the hiloLabel‘s text property
    
#pragma mark - ReactiveCocoa observables to reload data
    [[RACObserve([WeatherManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    
    [[RACObserve([WeatherManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[WeatherManager sharedManager] findCurrentLocation];
    
    //[[WeatherManager sharedManager] init];
    
} //end of viewDidLoad

-(UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;    
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgrounImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

//=================== TableView ========================//
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   //1
    //add one more cell for the header
    if (section == 0) {
        return MIN([[WeatherManager sharedManager].hourlyForecast count], 6) + 1;
    }
    
    //2
    return MIN([[WeatherManager sharedManager].dailyForecast count], 6) + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellIdentifier = @"CellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        //1
        if (indexPath.row == 0) {
            [self configureHeaderCell: cell title: @"今日天氣預報"];
        } else {
            //2
            WeatherCondition * weather = [WeatherManager sharedManager].hourlyForecast[indexPath.row - 1];
            [self configureHourlyCell:cell weather:weather];
        }
    }
    
    else if (indexPath.section == 1) {
        //1
        if (indexPath.row == 0) {
            [self configureHeaderCell: cell title:@"天氣預報"];
        } else {
            //3
            WeatherCondition * weather = [WeatherManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell: cell weather: weather];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //This divides the screen height by the number of cells in each section so the total height of all cells equals the height of the screen
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

#pragma mark - configureHeaderCell
-(void) configureHeaderCell: (UITableViewCell *)cell title:(NSString *) title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WeatherCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:30];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°C",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(WeatherCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:25];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°C / %.0f°C",
                                 weather.tempHigh.floatValue,
                                 weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - UIScrollViewDelegate
-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    //1
    //Cap the offset at 0 so attempting to scroll past the start of the table won’t affect blurring
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    
    //2
    //Divide the offset by the height with a maximum of 1 so that your offset is capped at 100%
    CGFloat percent = MIN(position / height, 1.0);
    
    //3
    //Assign the resulting value to the blur image’s alpha property to change how much of the blurred image you’ll see as you scroll
    self.blurredImageView.alpha = percent;
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
