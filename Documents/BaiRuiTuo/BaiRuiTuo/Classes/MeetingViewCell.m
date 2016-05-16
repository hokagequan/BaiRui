//
//  MeetingViewCell.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/14.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "MeetingViewCell.h"
#import "Define.h"

@implementation MeetingViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.leftButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.centerButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)buttonClicked:(UIButton*)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(meetingViewCell:didClickedButtonWithTag:)]) {
        [self.delegate meetingViewCell:self didClickedButtonWithTag:button.tag];
    }
}

- (void)setState:(NSInteger)state
{
    _state = state;
    BOOL enabled = NO;
    BOOL showTwoButton = NO;
    BOOL beforeMeeting = NO;
    NSString *stateString = nil;
    switch (state) {
        case BeforeMeetingState:
            stateString = @"会议未开";
            enabled = YES;
            showTwoButton = YES;
            beforeMeeting = YES;
            break;
        case InMeetingState:
            stateString = @"会议进行中";
            enabled = YES;
            showTwoButton = NO;
            break;
        case AfterMeetingState:
            stateString = @"会议结束";
            enabled = YES;
            showTwoButton = YES;
            break;
        case UploadedState:
            stateString = @"已同步";
            enabled = YES;
            showTwoButton = YES;
            break;
        case CancelByServerState:
            stateString = @"OPERA中已取消";
            enabled = NO;
            showTwoButton = NO;
            break;
        case CancelByAppState:
            stateString = @"会议取消";
            enabled = NO;
            showTwoButton = NO;
            break;
        case ExpiredState:
            stateString = @"会议过期";
            enabled = NO;
            showTwoButton = NO;
            break;
            
        default:
            break;
    }
    self.stateLabel.text = stateString;
    if (enabled) {
        self.numberLabel.textColor = kAppMainColor;
        self.typeLabel.textColor = kAppMainColor;
        self.dateLabel.textColor = kAppMainColor;
        self.nameLabel.textColor = kAppMainColor;
        self.officeLabel.textColor = kAppMainColor;
        self.stateLabel.textColor = kAppMainColor;
        self.centerButton.enabled = YES;
    }
    else {
        self.numberLabel.textColor = kAppGrayColor;
        self.typeLabel.textColor = kAppGrayColor;
        self.dateLabel.textColor = kAppGrayColor;
        self.nameLabel.textColor = kAppGrayColor;
        self.officeLabel.textColor = kAppGrayColor;
        self.stateLabel.textColor = kAppGrayColor;
        self.centerButton.enabled = NO;
    }
    if (showTwoButton) {
        self.centerButton.hidden = YES;
        self.leftButton.hidden = NO;
        self.rightButton.hidden = NO;
    }
    else {
        self.centerButton.hidden = NO;
        self.leftButton.hidden = YES;
        self.rightButton.hidden = YES;
    }
    if (beforeMeeting) {
        self.leftButton.selected = YES;
        self.rightButton.selected = YES;
    }
    else {
        self.leftButton.selected = NO;
        self.rightButton.selected = NO;
    }
}

@end
