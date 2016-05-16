//
//  BRTProgressViewController.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/15.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "BRTProgressViewController.h"

@interface BRTProgressViewController ()

@end

@implementation BRTProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.actIndView startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissWithMessage:(NSString*)message animated:(BOOL)animated
{
    [self.actIndView stopAnimating];
    self.tipLabel.text = message;
    if (animated) {
        [self.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2];
    }
    else {
        [self.view removeFromSuperview];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
