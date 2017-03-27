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
#import "Definitions.h"

@interface TodayViewController () <NCWidgetProviding, UITableViewDelegate, UITableViewDataSource> {

    NSMutableArray * eventsArray;
}

@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentWeatherConditionsLabel;
@property (weak, nonatomic) IBOutlet UITableView *eventsTable;

@end

@implementation TodayViewController

#pragma mark - VIEWS
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeCompact|NCWidgetDisplayModeExpanded;
    
    _eventsTable.delegate = self;
    _eventsTable.dataSource = self;
    
    [self updateWidgetInfo];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    self.eventsTable.backgroundColor = [UIColor clearColor];
    self.preferredContentSize = CGSizeMake(0, 100.0);
}

#pragma mark - WIDGET
- (void) widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    
    if (activeDisplayMode == NCWidgetDisplayModeExpanded) {
        self.preferredContentSize = CGSizeMake(320.0, 320.0);
        
    } else if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = CGSizeMake(0, 100.0);
    }
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    self.preferredContentSize = CGSizeMake(320.0, 320.0);
    [self updateWidgetInfo];

    [_eventsTable reloadData];
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
    
/// MARK: temperature
    NSString * temperatureTxt = [defaults stringForKey:@"currentTempTxt"];
    self.currentTempLabel.numberOfLines = 0;
    self.currentTempLabel.adjustsFontSizeToFitWidth = true;
    self.currentTempLabel.text = temperatureTxt;
    
    NSString * currentConditions = [defaults stringForKey:@"currentConditions"];
    self.currentWeatherConditionsLabel.text = currentConditions;
    self.currentWeatherConditionsLabel.adjustsFontSizeToFitWidth = true;
    
/// MARK: Events calendar
    eventsArray = [NSMutableArray new];
    eventsArray = [[defaults arrayForKey:@"eventsArray"] mutableCopy];
    [_eventsTable reloadData];
}

#pragma mark - TABLEVIEW DELEGATE
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
        cell.timeLabel.text = @"";
    }
    else{
        cell.titleLabel.text = eventsArray[indexPath.row][@"event title"];
        cell.timeLabel.text = eventsArray[indexPath.row][@"today date"];
    }
    [cell.titleLabel setFont:[UIFont systemFontOfSize:25]];
    [cell.titleLabel setAdjustsFontSizeToFitWidth:true];
    [cell.titleLabel setNumberOfLines:0];
    
    [cell.timeLabel setFont: [UIFont systemFontOfSize:20]];
    [cell.timeLabel setNumberOfLines:0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL * appURL = [NSURL URLWithString:@"activeAging://"];
    
    [self.extensionContext openURL:appURL completionHandler:^(BOOL success) {
        
        NSError * error;
        
        if (error) {
            NSLog(@"%@", error.description);
        }
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
