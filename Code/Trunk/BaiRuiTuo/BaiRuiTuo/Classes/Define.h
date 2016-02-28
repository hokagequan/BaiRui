//
//  Define.h
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/14.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#ifndef BaiRuiTuo_Define_h
#define BaiRuiTuo_Define_h

#define kAppMainColor [UIColor colorWithRed:79/255.0 green:45/255.0 blue:127/255.0 alpha:1]
#define kAppPinkColor [UIColor colorWithRed:236/255.0 green:0 blue:140/255.0 alpha:1]
#define kAppGrayColor [UIColor colorWithRed:128/255.0 green:127/255.0 blue:131/255.0 alpha:1]
#define kBRTMeetingStates @[@"会议未开",@"会议进行中",@"会议结束",@"已同步",@"OPERA中已取消",@"会议取消",@"会议过期"]

#define kBRTRemberPasswordKey   @"BRTRemberPassword"
#define kBRTUsernameKey         @"BRTUsername"
#define kBRTPasswordKey         @"BRTPassword"

// 测试地址
#define kBRTOPERAServerURL @"http://bsgsgps0358.ap.bayer.cnb:8100"
//旧地址#define kBRTOPERAServerURL @"http://bsgsgps0355.ap.bayer.cnb:8100"
#ifdef TEST
#define kBRTOPERAServerURL @"http://bcnshgs0130.ap.bayer.cnb:8100"
#else
#ifdef DEBUG
//#define kBRTOPERAServerURL @"http://bcnshgs0130.ap.bayer.cnb:8100"
#else
//生产环境
// 2015-06-09，服务器地址变动
//#define kBRTOPERAServerURL @"http://bcnshgs0130.ap.bayer.cnb:8100"
#endif
#endif
#ifdef DEBUG
#define kBRTMeetingRecordURL @"http://www.bayernorth.com"
//www.bayernorth.com 192.168.8.27
//#define kBRTMeetingRecordURL @"http://bsgsgps0506.ap.bayer.cnb:8000"
////CHDWA，CHBFD测试环境有活动信息
#else
#define kBRTMeetingRecordURL @"http://bsgsgps0506.ap.bayer.cnb:8000"
#endif

#endif
