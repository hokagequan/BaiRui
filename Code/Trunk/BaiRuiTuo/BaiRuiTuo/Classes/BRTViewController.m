//
//  BRTViewController.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/13.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "BRTViewController.h"
#import "LoginViewController.h"

@interface BRTViewController ()

@end

@implementation BRTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_logout.png"] style:UIBarButtonItemStylePlain target:self action:@selector(logoutAction)];
    
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (void)logoutAction
//{
//    [LoginViewController logout];
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

@end
