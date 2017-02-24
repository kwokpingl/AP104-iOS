//
//  TodayViewController.m
//  ActiveAgingWidget
//
//  Created by Ga Wai Lau on 2/12/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "WidgetEventTableViewCell.h"

#define WIDGET_NAME @"group.ActiveAging.TodayExtensionSharingDefaults"

@interface TodayViewController () <NCWidgetProviding, UITableViewDelegate, UITableViewDataSource> {

    NSMutableArray * eventsArray;
}

@property (weak, nonatomic) IBOutlet UIImageView *weatherImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentWeatherConditionsLabel;
@property (weak, nonatomic) IBOutlet UITableView *eventsTable;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.preferredContentSize = CGSizeMake(320.0, 320.0);
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    _eventsTable.delegate = self;
    _eventsTable.dataSource = self;
    [self updateWidgetInfo];
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void) widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    
    if (activeDisplayMode == NCWidgetDisplayModeExpanded) {
        self.preferredContentSize = CGSizeMake(320.0, 320.0);
    } else if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = CGSizeMake(0, 100.0);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

#pragma mark - initWithCoder
- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark - user Default did change
- (void) userDefaultDidChange: (NSNotification *) notification {
    [self updateWidgetInfo];
}

#pragma mark - update Widget Info
- (void) updateWidgetInfo {
    
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:WIDGET_NAME];
    
#pragma mark - temperature
    NSString * temperatureTxt = [defaults stringForKey:@"currentTempTxt"];
    self.currentTempLabel.text = temperatureTxt;
    
    NSString * currentConditions = [defaults stringForKey:@"currentConditions"];
    self.currentWeatherConditionsLabel.text = currentConditions;
    
    NSString * imagePath = [defaults objectForKey:@"imageURL"];
    self.weatherImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    
    [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
    
#pragma mark - Events calendar
    eventsArray = [NSMutableArray new];
    eventsArray = [[defaults arrayForKey:@"eventsArray"] mutableCopy];
    
    [_eventsTable reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (eventsArray.count == 0) {
        return 1;
    }
    
    return eventsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WidgetEventTableViewCell * cell = [_eventsTable dequeueReusableCellWithIdentifier:@"Cell"];
    
     //Configure Cell
    [cell.titleLabel setNumberOfLines:0];
    if (eventsArray.count == 0) {
        cell.titleLabel.text = @"今天沒有任何活動唷。\n 養足精神，重新出發！";
    }
    else{
    
        cell.titleLabel.text = eventsArray[indexPath.row][@"event title"];
    }
    
    cell.timeLabel.text = eventsArray[indexPath.row][@"today date"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
