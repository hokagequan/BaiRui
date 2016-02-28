//
//  BRTMeetingModel.h
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/21.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRTMeetingDetailModel.h"

typedef NS_ENUM(NSUInteger, BRTMeetingState) {
    BeforeMeetingState = 0,
    InMeetingState,
    AfterMeetingState,
    UploadedState,
    CancelByServerState,
    CancelByAppState,
    ExpiredState,
    InvalidState
};

@interface BRTMeetingModel : NSObject

@property (nonatomic, strong) NSString *meetingID;
@property (nonatomic, strong) NSString *meetingType;
@property (nonatomic, strong) NSString *meetingTime;
@property (nonatomic, strong) NSString *meetingName;
@property (nonatomic, strong) NSString *meetingOffice;
@property (nonatomic, strong) NSNumber *meetingState;
@property (nonatomic, strong) NSString *requesterCWID;
@property (nonatomic, strong) NSString *submitterCWID;
@property (nonatomic, strong) BRTMeetingDetailModel *meetingDetail;
@property (nonatomic, strong) NSDate *beginTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSDate *uploadTime;

@end
