//
//  EventDetailOuterTableViewCell.m
//  ActiveAging_v1.0
//
//  Created by Kwok Ping Lau on 1/23/17.
//  Copyright © 2017 PING. All rights reserved.
//

#import "EventDetailOuterTableViewCell.h"
#import "EventDetailInnerTableViewCell.h"
#import <UIKit/UIKit.h>

static int showDetail;

@interface EventDetailOuterTableViewCell() <UITableViewDelegate,UITableViewDataSource>

@end

@implementation EventDetailOuterTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    

    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    showDetail ++;
    if (showDetail > 1){
        showDetail = 0;
//        _InnerTableView.delegate = self;
//        _InnerTableView.dataSource = self;
    }
    _OuterBottomContentHeightContraint.priority = (showDetail==1)?250:999;
}


-(void)layoutSubviews{
    [super layoutSubviews];
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    EventDetailInnerTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"innerCell"];
//    
//    cell.textLabel.text = @"NICE";
//    return cell;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 10;
//}



@end
