//
//  BRTAlertViewController.h
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/15.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRTAlertViewController : UIViewController

@property (nonatomic, strong) NSString *message;

- (void)addActionWithHandler:(void (^)(void))handler;

@end
