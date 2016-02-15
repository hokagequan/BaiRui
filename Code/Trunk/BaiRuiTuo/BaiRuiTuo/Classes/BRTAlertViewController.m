//
//  BRTAlertViewController.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/15.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "BRTAlertViewController.h"
#import <objc/runtime.h>

@interface BRTAlertViewController ()

@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

- (IBAction)yesButtonClicked:(UIButton *)sender;
- (IBAction)noButtonClicked:(UIButton *)sender;

@end

@implementation BRTAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    self.msgLabel.text = self.message;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    self.msgLabel.text = message;
}

- (void)addActionWithHandler:(void (^)(void))handler
{
    objc_setAssociatedObject(self, @"BRTAlertAction", handler, OBJC_ASSOCIATION_COPY);
}

- (IBAction)yesButtonClicked:(UIButton *)sender {
    [self.view removeFromSuperview];
    
    void (^block)() = objc_getAssociatedObject(self, @"BRTAlertAction");
    if (block) {
        block();
    }
}

- (IBAction)noButtonClicked:(UIButton *)sender {
    [self.view removeFromSuperview];
}
@end
