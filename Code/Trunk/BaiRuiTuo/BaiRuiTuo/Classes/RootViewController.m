//
//  RootViewController.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/8.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "RootViewController.h"
#import "MeetingViewController.h"
#import "HospitalTableViewController.h"
#import "Define.h"
#import "AFNetworking.h"
#import "BRTMeetingManager.h"
#import "LoginViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择会议类型";
    // Do any additional setup after loading the view, typically from a nib.
    [self performSelector:@selector(checkLoginInfo) withObject:nil afterDelay:0.5];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkLoginInfo
{
    [LoginViewController checkInBackgroundSuccess:^{
        
    } failure:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMeeting"]) {
        MeetingViewController *dvc = segue.destinationViewController;
        dvc.title = @"城市会议列表";
        dvc.meetingType = BRTCityMeeting;
    }
    else if ([segue.identifier isEqualToString:@"showHospital1"]) {
        HospitalTableViewController *dvc = segue.destinationViewController;
        dvc.meetingType = BRTOfficeMeeting;
    }
    else if ([segue.identifier isEqualToString:@"showHospital2"]) {
        HospitalTableViewController *dvc = segue.destinationViewController;
        dvc.meetingType = BRTHospitalMeeting;
    }
}

@end
