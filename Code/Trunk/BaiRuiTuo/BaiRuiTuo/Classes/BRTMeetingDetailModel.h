//
//  BRTMeetingDetailModel.h
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/21.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BRTImageType) {
    BeforeMeetingType,
    InMeetingType,
    AfterMeetingType,
    RefreshmentsType,
    CarsType,
    MealsType,
    OthersType
};

@interface BRTMeetingDetailModel : NSObject

@property (nonatomic, strong) NSMutableArray *beforeMeetingImages;
@property (nonatomic, strong) NSMutableArray *inMeetingImages;
@property (nonatomic, strong) NSMutableArray *afterMeetingImages;
@property (nonatomic, strong) NSMutableArray *teaBreakImages;
@property (nonatomic, strong) NSMutableArray *carServiceImages;
@property (nonatomic, strong) NSMutableArray *diningImages;
@property (nonatomic, strong) NSMutableArray *otherImages;

@end
