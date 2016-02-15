//
//  ImageScrollViewController.h
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/15.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBRTImageDidDeleteNotification @"BRTImageDidDeleteNotification"

@interface ImageScrollViewController : UIViewController

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic, assign) BOOL hidesDeleteButton;
@property (nonatomic, assign) int minImageCount;

@end
