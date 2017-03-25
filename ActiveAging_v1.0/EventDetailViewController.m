//
//  EventDetailViewController.m
//  ActiveAging_v1.0
//
//  Created by meichang on 2017/2/12.
//  Copyright © 2017年 PING. All rights reserved.
//

#import "EventDetailViewController.h"
#import "ImageManager.h"
#import "ServerManager.h"
#import "UserInfo.h"
#import "EventManager.h"
#import "DataManager.h"

#import "OrganizationViewController.h"
#import "DescriptionViewController.h"
#import "LocationViewController.h"
#import "TimeViewController.h"

#define SIDEBAR_SIDE_SPACE 10
#define SIDEBAR_INTER_SPACE 20
#define SIDEBAR_TOP_INIT_SPACE 44

typedef enum : NSUInteger {
    btnOrganization,
    btnDescription,
    btnLocation,
    btnTime
} EVENT_DATA;

@interface EventDetailViewController () {
    NSArray <UIButton*> * buttonArray;
    NSArray * segueDestination;
    NSArray * destinationViewControllers;
    ServerManager * _serverMgr;
    UserInfo * _userInfo;
    EventManager * _eventMgr;
}
@property (weak, nonatomic) IBOutlet UIView * sidebarView;
@property (strong, nonatomic) IBOutlet UIButton * firstButton;
@property (strong, nonatomic) IBOutlet UIButton * secondButton;
@property (strong, nonatomic) IBOutlet UIButton * thirdButton;
@property (strong, nonatomic) IBOutlet UIButton * fourthButton;
@property (strong, nonatomic) IBOutlet UIImage * image;
@property (strong, nonatomic) UIViewController * currentVC;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation EventDetailViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    NSLog(@"%@", _eventDetailDict);
    
    _serverMgr = [ServerManager shareInstance];
    _userInfo = [UserInfo shareInstance];
    _eventMgr = [EventManager shareInstance];
    [self sideBarSetup];
    [self setImage];
    [self setupNavigation];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       [self requestAccessToEventType];
    });
    
    
    destinationViewControllers = @[
                                   @"OrganizationViewController",
                                   @"DescriptionViewController",
                                   @"LocationViewController",
                                   @"TimeViewController"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    for (UIView * view in [_scrollView subviews]){
        [view removeFromSuperview];
    }
    [self hideContentController:_currentVC];
}




#pragma mark - PRIVATE METHODS
- (void) sideBarSetup {
    _firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _fourthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    buttonArray = @[_firstButton,
                    _secondButton,
                    _thirdButton,
                    _fourthButton];
    NSArray * buttonNames = @[@"舉辦單位", @"活動簡介", @"活動地點", @"活動時間"];
    CGFloat frame_width = _sidebarView.frame.size.width;
    CGFloat frame_height = _sidebarView.frame.size.height;
    
    CGFloat topSpace = SIDEBAR_TOP_INIT_SPACE;
    CGFloat height = (frame_height - topSpace)/(buttonArray.count + 2);
    
    for (int i = 0; i < buttonArray.count; i++){
        
        CGRect buttonFrame = CGRectMake(SIDEBAR_SIDE_SPACE, topSpace, frame_width - 2 * SIDEBAR_SIDE_SPACE, height );
        topSpace += height + SIDEBAR_INTER_SPACE;
        
        NSLog(@"%@", buttonNames[i]);
        NSLog(@"ORIGIN: (%.2f, %.2f)\nWIDTH: %.2f\nHEIGTH: %.2f",
              buttonFrame.origin.x, buttonFrame.origin.y, buttonFrame.size.width, buttonFrame.size.height);
        UIButton * temp = nil;
        
        temp = (UIButton *) buttonArray[i];
        
        NSLog(@"%@",temp==buttonArray[i]?@"True":@"False");
        
        [temp setFrame:buttonFrame];
        [temp setTitle:buttonNames[i] forState:UIControlStateNormal];
        [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [temp setTag:i];
        [temp addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [temp setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [temp setBackgroundImage:[self imageWithColor:[UIColor brownColor]] forState:UIControlStateDisabled];
        
        if (i == 0) {
            [temp setEnabled:false];
        }
        [self.view addSubview:temp];
    }
}


- (void) setImage {
    // GET IMAGE
    [ImageManager getEventImage:_eventDetailDict[EVENT_PIC_KEY] completion:^(NSError *error, id result) {
        if (!error){
            _image = [UIImage imageWithData:result];
            dispatch_async(dispatch_get_main_queue(), ^{
                OrganizationViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:destinationViewControllers[0]];
                vc.eventDictionary = [[NSDictionary alloc] initWithDictionary:_eventDetailDict];
                vc.image = _image;
                _currentVC = vc;
                [self displayContentController:vc];
            });
            
        }
        else{
            _image = nil;
        }
    }];
}

#pragma mark - CONTAINER METHODS
- (void) displayContentController: (UIViewController *) content{
    
    [content willMoveToParentViewController:self];
    [self addChildViewController:content];
    [_scrollView addSubview:content.view];
    
    [_scrollView setContentSize:content.view.frame.size];
    _currentVC = content;
}

- (void) hideContentController: (UIViewController*) content {
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void) changeSubviews: (UIViewController *) newVC {
    for (UIView * view in [_scrollView subviews]){
        [view removeFromSuperview];
    }
    [_currentVC willMoveToParentViewController:nil];
    
    UIView * view = newVC.view;
    [view setFrame:_currentVC.view.frame];
    [_scrollView setContentOffset:CGPointZero];
    [_scrollView addSubview:view];
    [_scrollView setContentSize:CGSizeMake(view.frame.size.width, view.frame.size.height+200)];
    _currentVC = newVC;
}

- (void) setupNavigation {
    NSString * joinButtonName;
    
    if (_eventDetailDict[USER_EVENT_STATUS_KEY]){
        joinButtonName = @"不感興趣";
    } else {
        joinButtonName = @"感興趣";
    }
    UIBarButtonItem * joinButtonItem = [[UIBarButtonItem alloc] initWithTitle:joinButtonName style:UIBarButtonItemStylePlain target:self action:@selector(joinBtnPressed:)];
    [self.navigationItem setRightBarButtonItem:joinButtonItem];
}


#pragma mark - BUTTONS
- (void) buttonPressed: (UIButton *) sender{
    for (UIButton * button in buttonArray){
        [button setEnabled:true];
    }
    [sender setEnabled:false];
    switch (sender.tag) {
        case btnOrganization:
        {
            NSLog(@"ORGANIZATION");
            OrganizationViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:destinationViewControllers[btnOrganization]];
            vc.eventDictionary = [[NSDictionary alloc] initWithDictionary:_eventDetailDict];
            vc.image = _image;
            [self changeSubviews:vc];
        }
            break;
        case btnDescription:
        {
            NSLog(@"CONTENT");
            DescriptionViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:destinationViewControllers[btnDescription]];
            vc.eventDetailDict = [[NSDictionary alloc] initWithDictionary:_eventDetailDict];
            [self changeSubviews:vc];
        }
            break;
        case btnLocation:
        {
            NSLog(@"LOCATION");
            LocationViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:destinationViewControllers[btnLocation]];
            vc.eventDetailDict = [[NSDictionary alloc] initWithDictionary:_eventDetailDict];
            [self changeSubviews:vc];
        }
            break;
        case btnTime:
        {
            NSLog(@"TIME");
            TimeViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:destinationViewControllers[btnTime]];
            vc.eventDetailDict = [[NSDictionary alloc] initWithDictionary:_eventDetailDict];
            [self changeSubviews:vc];
        }
            break;
        default:
            break;
    }
    
}


- (void) returnButtonPressed {
    [self.navigationController popViewControllerAnimated:true];
}


- (IBAction)joinBtnPressed:(UIBarButtonItem *)sender {
    NSString * action;
    
    if ([sender.title isEqualToString:@"感興趣"]){
        NSDictionary * eventDetail = @{EVENT_START_KEY:_eventDetailDict[EVENT_START_KEY],
                                       EVENT_END_KEY: _eventDetailDict[EVENT_END_KEY],
                                       EVENT_TITLE_KEY: _eventDetailDict[EVENT_TITLE_KEY],
                                       EVENT_ADDRESS_KEY: _eventDetailDict[EVENT_ADDRESS_KEY],
                                       EVENT_DESCRIPTION_KEY: _eventDetailDict[EVENT_DESCRIPTION_KEY]
                                       };
        [_eventMgr checkNewEvent:eventDetail complete:^(NSMutableArray *eventArray) {
            [self isNewEventAdded:([eventArray[0] intValue] == 1)?true:false];
                
        }];
        
        
    }else {
        action = USER_EVENT_QUIT;
        [_serverMgr retrieveEventInfo:action UserID:_userInfo.getUserID EventID:_eventDetailDict[EVENT_ID_KEY] completion:^(NSError *error, id result) {
            NSString * alertTitle, * alertMessage;
            if ([result[ECHO_RESULT_KEY] boolValue]){
                alertTitle = @"成功退出";
                alertMessage = @"系統以消除此項目";
                
                [self requestAccessToEventType];
                
                NSDictionary * eventDetail = @{EVENT_START_KEY:_eventDetailDict[EVENT_START_KEY],
                                                                     EVENT_END_KEY: _eventDetailDict[EVENT_END_KEY],
                                                                     EVENT_TITLE_KEY: _eventDetailDict[EVENT_TITLE_KEY],
                                                                     EVENT_ADDRESS_KEY: _eventDetailDict[EVENT_ADDRESS_KEY],
                                                                     EVENT_DESCRIPTION_KEY: _eventDetailDict[EVENT_DESCRIPTION_KEY]
                                                                     };
                [_eventMgr eventToBeRemoved:eventDetail complete:^(NSMutableArray *eventArray) {
                    if ([eventArray.lastObject boolValue]){
                        NSLog(@"SUCCESS");
                        [DataManager updateEventDatabase];
                    }else{
                        NSLog(@"FAILED");
                    }
                }];
            }else{
                alertTitle = @"失敗";
                alertMessage = @"請與開發者聯繫,並敘述發生的問題。";
            }
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [delegate updateList];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self returnButtonPressed];
                });
            }];
            
            [alert addAction:ok];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:true completion:nil];
            });
        }];
    }
    
    [DataManager updateEventDatabase];

}


#pragma mark - CALENDAR METHODS
/// MARK: REQUEST_ACCESS_TO_EVENT_TYPE
-(void) requestAccessToEventType {
    [_eventMgr requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"%@", error);
            return;
        }
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"無法存取" message:@"「哈啦哈啦趣」無法存取您的行事曆。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * ok = [UIAlertAction actionWithTitle:@"瞭解" style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction * redirect = [UIAlertAction actionWithTitle:@"設定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [alert addAction:ok];
                [alert addAction:redirect];
                
                [self presentViewController:alert animated:YES completion:nil];
            });
            
            return;
        }
        
        _eventMgr.eventsAccessGranted = granted;    }];
}


/// MARK: CHECK_IF_EVENT_IS_ADDED
-(void) isNewEventAdded: (BOOL) isAdded {
    if (isAdded) {
        
        NSDictionary * eventDetail = @{EVENT_START_KEY:_eventDetailDict[EVENT_START_KEY],
                                       EVENT_END_KEY: _eventDetailDict[EVENT_END_KEY],
                                       EVENT_TITLE_KEY: _eventDetailDict[EVENT_TITLE_KEY],
                                       EVENT_ADDRESS_KEY: _eventDetailDict[EVENT_ADDRESS_KEY],
                                       EVENT_DESCRIPTION_KEY: _eventDetailDict[EVENT_DESCRIPTION_KEY]
                                       };
        
        [_eventMgr newEventToBeAdded:eventDetail complete:^(NSMutableArray *eventArray) {
        }];
        
        NSString * action = USER_EVENT_JOIN;
        [_serverMgr retrieveEventInfo:action
                               UserID:_userInfo.getUserID
                              EventID:_eventDetailDict[EVENT_ID_KEY] completion:^(NSError *error, id result) {
                                  
                                  if ([result[ECHO_RESULT_KEY] boolValue]){
                                      UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"耶！存好了。" message:@"您可以在月曆上瀏覽新增的活動喔。\n請與舉辦單位聯繫以完成加入活動手續。" preferredStyle:UIAlertControllerStyleAlert];
                                      
                                      UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"好，我知道了。" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                          [delegate updateList];
                                          [self returnButtonPressed];
                                      }];
                                      
                                      [alert addAction:okAction];
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self presentViewController:alert animated:YES completion:nil];
                                      });
                                  }
                                  else{
                                      
                                      UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"出現錯誤" message:@"活動紀錄失敗。\n請稍後再試。" preferredStyle:UIAlertControllerStyleAlert];
                                      
                                      UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"好，我知道了。" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                          
                                          [_eventMgr eventToBeRemoved:eventDetail complete:^(NSMutableArray *eventArray) {
                                              
                                          }];
                                          [delegate updateList];
                                          [self returnButtonPressed];
                                      }];
                                      
                                      [alert addAction:okAction];
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self presentViewController:alert animated:true completion:nil];
                                      });

                                  }
                                  
                                  }];
        [DataManager updateEventDatabase];
        
    }
    else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"哇~沒存到。" message:@"你這段時間已經有活動了唷。" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"好，我知道了。" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [delegate updateList];
            [self returnButtonPressed];
        }];
        
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
 
 return image;
}


@end
