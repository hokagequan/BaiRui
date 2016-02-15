//
//  MeetingViewCell.h
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/14.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTMeetingModel.h"

@protocol MeetingViewCellDelegate;

@interface MeetingViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *officeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIView *operationView;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (assign, nonatomic) id <MeetingViewCellDelegate> delegate;
@property (assign, nonatomic) NSInteger state;

@end

@protocol MeetingViewCellDelegate <NSObject>

- (void)meetingViewCell:(MeetingViewCell*)cell didClickedButtonWithTag:(NSInteger)tag;

@end