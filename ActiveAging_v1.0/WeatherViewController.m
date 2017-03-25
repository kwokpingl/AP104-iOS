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

//static NSInteger counter = 0;
static dispatch_once_t onceToken;

#define WIDGET_NAME @"group.ActiveAging.TodayExtensionWidgetSharingDefaults"
@interface WeatherViewController ()  {
    UILabel * temperatureLabel;
    UILabel * conditionsLabel;
    UIImageView * iconView;
    UILabel * hiloLabel;
    NSString * imageName;
    UIImage * bkg;
}

@property UIImageView * backgroundImageView;

@property UITableView * tableView;
@property (nonatomic, assign) CGFloat screenHeight;

@property NSDateFormatter * hourlyFormatter;
@property NSDateFormatter * dailyFormatter;

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
        _dailyFormatter.dateFormat = @"EEEE";
        _dailyFormatter.locale = twLocale;
    }
    return self;
}

#pragma mark - VIEW
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"TestViewController Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef) self));
    [self pageSetup];
    
/// MARK: Observe the current Condition
    
    //1
    //Observes the currentCondition key on the WeatherManager singleton
    [[RACObserve([WeatherManager sharedManager], currentCondition)
      //2
      //Delivers any changes on the main thread since you’re updating the UI
      deliverOn: RACScheduler.mainThreadScheduler]
     subscribeNext: ^(WeatherCondition * newCondition) {
         
         if (newCondition!=nil){
             dispatch_async(dispatch_get_main_queue(), ^{
                 // 3
                 //Updates the text labels with weather data; you’re using newCondition for the text and not the singleton. The subscriber parameter is guaranteed to be the new value
                 temperatureLabel.text = [NSString stringWithFormat:@"%.0f°C",newCondition.temperature.floatValue];
                 conditionsLabel.text = [newCondition.condition capitalizedString];
                 
                 // 4
                 //Uses the mapped image file name to create an image and sets it as the icon for the view
                 
                 NSDate * date = [NSDate date];
                 NSDateFormatter * dateformat = [NSDateFormatter new];
                 dateformat.dateFormat = @"HH";
                 NSString * currentdate = [dateformat stringFromDate:date];
                 
                 if ([[newCondition imageName] containsString:@"few"]) {
                     if ([currentdate floatValue] >= 18.0 || [currentdate floatValue] <= 6.0) {
                         iconView.image = [UIImage imageNamed:@"few-night"];
                         
                     } else {
                         iconView.image = [UIImage imageNamed:@"few-day"];
                     }
                 }
                 else {
                     iconView.image = [UIImage imageNamed:[newCondition imageName]];
                 }
                 
                 imageName = [newCondition imageName];
                 
                 [self.backgroundImageView setImage:[self setBackgroundImage]];
                 
                 self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
                 
                 for (UIView * view in self.view.subviews){
                     if ([view isKindOfClass:[UIImageView class]]){
                         [view removeFromSuperview];
                         NSLog(@"VIEW FOUND");
                     }
                 }
                 
                 [self.view insertSubview:_backgroundImageView atIndex:0];
                 
                 [self widgetConfiguration];
             });

         }
         
     }];
    
/// MARK: ReactiveCocoa Bindings
    [self.view insertSubview:_backgroundImageView atIndex:0];
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
    
/// MARK: ReactiveCocoa observables to reload data
    [[RACObserve([WeatherManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
         });
     }];
    
    
    [[RACObserve([WeatherManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         dispatch_async(dispatch_get_main_queue(), ^{
           [self.tableView reloadData];
         });
     }];
    
    [[WeatherManager sharedManager] findCurrentLocation];

    
} //end of viewDidLoad

- (void)viewWillDisappear:(BOOL)animated {
    
    _backgroundImageView = nil;
    _tableView = nil;
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
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
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //This divides the screen height by the number of cells in each section so the total height of all cells equals the height of the screen
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

/// MARK: CONFIGURE_HEADER_CELL
-(void) configureHeaderCell: (UITableViewCell *)cell title:(NSString *) title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WeatherCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:30];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:30];
    
    NSLocale * twLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    
    _hourlyFormatter = [NSDateFormatter new];
    _hourlyFormatter.dateFormat = @"h a";
    _hourlyFormatter.locale = twLocale;
    
    NSString * weatherDate = [_hourlyFormatter stringFromDate:weather.date];
    cell.textLabel.text = weatherDate;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°C",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    NSLog(@"%@",imageName);
    NSLog(@"%@",cell.imageView.image);
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(WeatherCondition *)weather {
    
    NSLocale * twLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    _dailyFormatter = [NSDateFormatter new];
    _dailyFormatter.dateFormat = @"EEEE";
    _dailyFormatter.locale = twLocale;
    
    NSString * dailyWeather = [_dailyFormatter stringFromDate:weather.date];
    cell.textLabel.text = dailyWeather;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:25];
    
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:25];
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
    CGFloat declineHeight = height/6.0;
    CGFloat alpha;
    UIBlurEffect * blur;
    UIVisualEffectView * effectView;
    CGFloat currentHeight = scrollView.contentOffset.y;
    
    
    
    if (currentHeight >= declineHeight){
    
        blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        [effectView setBackgroundColor:[UIColor clearColor]];
        [effectView setFrame:_backgroundImageView.bounds];
        dispatch_once(&onceToken, ^{
            [_backgroundImageView addSubview:effectView];
        });
        
    }
    else if (currentHeight < declineHeight){
        alpha = 1;
        effectView = nil;
        for(UIView * view in self.backgroundImageView.subviews){
            if ([view isKindOfClass:[UIVisualEffectView class]]){
                [view removeFromSuperview];
            }
        }
        onceToken = 0;
    }
}


#pragma mark - PRIVATE METHODS
- (UIImage * ) setBackgroundImage {
    
    NSDate * date = [NSDate date];
    NSDateFormatter * dateformat = [NSDateFormatter new];
    dateformat.dateFormat = @"HH";
    NSString * currentdate = [dateformat stringFromDate:date];
    
    if ([imageName isEqualToString:@"tstorm"]) {
        bkg = [UIImage imageNamed:@"tstormBg"];
    }
    
    else if ([imageName isEqualToString:@"moon"]) {
        bkg = [UIImage imageNamed:@"nightClear"];
    }
    
    else if ([imageName isEqualToString:@"rain"] || [imageName isEqualToString:@"shower"]) {
        bkg = [UIImage imageNamed:@"rainBg"];
    }
    
    else if ([imageName isEqualToString:@"sunny"] || [imageName containsString:@"clear"]) {
        
        if([currentdate floatValue] >= 18.0 || [currentdate floatValue] <= 6.0){
            bkg = [UIImage imageNamed:@"nightClear"];
        }
        else{
            bkg = [UIImage imageNamed:@"sunnyBg"];
        }
    }

    else if ([imageName isEqualToString:@"broken"] || [imageName containsString:@"few"]) {
        
        if ([currentdate floatValue] >= 18.0 || [currentdate floatValue] <= 6.0) {
            bkg = [UIImage imageNamed:@"brokenN"];
        } else {
            bkg = [UIImage imageNamed:@"sunset"];
        }
    }
    else if ([imageName isEqualToString:@"mist"]){
        bkg = [UIImage imageNamed:@"Fog"];
    }
    else {
        bkg = [UIImage imageNamed:@"LaunchScreen"];
    }
    return bkg;
}

- (void) pageSetup {
    /// MARK: set up Image View & table View
    //1
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    
    //4
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    
    [self.view addSubview:self.tableView];
    
    /// MARK: set up frames and margins
    //Set up layout frames and margins
    //1
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    //2
    CGFloat inset = 20;
    //3
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 80;
    
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
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 30);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 30);
    
    /// MARK: set up labels
    //1
    UIView * header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    //2 - bottom left
    temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor blackColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:120];
    [header addSubview:temperatureLabel];
    
    hiloLabel = [[UILabel alloc] initWithFrame: hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor blackColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:28];
    [header addSubview:hiloLabel];
    
    conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:45];
    conditionsLabel.textColor = [UIColor blackColor];
    conditionsLabel.numberOfLines = 0;
    conditionsLabel.adjustsFontSizeToFitWidth = true;
    [header addSubview: conditionsLabel];
    
    //3 - bottom left
    iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)dealloc {
    NSLog(@"DEALLOC");
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"TestViewController Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef) self));
}


#pragma mark - widgetConfiguration
-(void) widgetConfiguration {
    NSUserDefaults * sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:WIDGET_NAME];
    
    [sharedDefaults setObject:temperatureLabel.text forKey:@"currentTempTxt"];
    
    [sharedDefaults setObject:conditionsLabel.text forKey:@"currentConditions"];
    
    [sharedDefaults synchronize];
}


@end
