//
//  MeetingDetailViewController.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/14.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "MeetingDetailViewController.h"
#import "MeetingDetailButton.h"
#import "BRTAlertViewController.h"
#import "ImageTableViewController.h"
#import "SVProgressHUD.h"

@interface MeetingDetailViewController ()
{
    BOOL overOneDay;
}

@property (weak, nonatomic) IBOutlet MeetingDetailButton *beforeMeetingBtn;
@property (weak, nonatomic) IBOutlet MeetingDetailButton *duringMeetingBtn;
@property (weak, nonatomic) IBOutlet MeetingDetailButton *afterMeetingBtn;
@property (weak, nonatomic) IBOutlet MeetingDetailButton *teaBtn;
@property (weak, nonatomic) IBOutlet MeetingDetailButton *carBtn;
@property (weak, nonatomic) IBOutlet MeetingDetailButton *diningBtn;
@property (weak, nonatomic) IBOutlet MeetingDetailButton *othersBtn;
@property (strong, nonatomic) BRTAlertViewController *alerViewCtrl;
@property (nonatomic, strong) MeetingDetailButton *selectedButton;

- (IBAction)buttonClicked:(MeetingDetailButton *)sender;

@end

@implementation MeetingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会议照片";
    // Do any additional setup after loading the view.
    
    self.alerViewCtrl = [[BRTAlertViewController alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    BRTMeetingModel *currentMeeting = [[BRTMeetingManager sharedManager] currentMeeting];
    if ([currentMeeting.meetingState integerValue] == InMeetingState) {
        if (currentMeeting.endTime) {
            currentMeeting.meetingState = @(AfterMeetingState);
            [[BRTMeetingManager sharedManager] updateValue:@(AfterMeetingState) forKey:kBRTMeetingStateKey withMeetingID:currentMeeting.meetingID];
        }
    }
}

- (void)loadData
{
    self.beforeMeetingBtn.countLabel.text = [NSString stringWithFormat:@"%@张", @(self.meetingDetail.beforeMeetingImages.count)];
    self.duringMeetingBtn.countLabel.text = [NSString stringWithFormat:@"%@张", @(self.meetingDetail.inMeetingImages.count)];
    self.afterMeetingBtn.countLabel.text = [NSString stringWithFormat:@"%@张", @(self.meetingDetail.afterMeetingImages.count)];
    self.teaBtn.countLabel.text = [NSString stringWithFormat:@"%@张", @(self.meetingDetail.teaBreakImages.count)];
    self.carBtn.countLabel.text = [NSString stringWithFormat:@"%@张", @(self.meetingDetail.carServiceImages.count)];
    self.diningBtn.countLabel.text = [NSString stringWithFormat:@"%@张", @(self.meetingDetail.diningImages.count)];
    self.othersBtn.countLabel.text = [NSString stringWithFormat:@"%@张", @(self.meetingDetail.otherImages.count)];
    
    //如果会前照片数量不足，不允许拍会中会后照片
    if (self.meetingDetail.beforeMeetingImages.count >= 2) {
        self.duringMeetingBtn.enabled = YES;
        self.afterMeetingBtn.enabled = YES;
        self.beforeMeetingBtn.cameraButton.enabled = NO;
    }
    else {
        self.duringMeetingBtn.enabled = NO;
        self.afterMeetingBtn.enabled = NO;
//        self.beforeMeetingBtn.cameraButton.enabled = YES;
    }
    // 2015-04-01, 会中照片不马上锁定
//    //如果会中照片不够2张，不允许拍会后照片
//    if (self.meetingDetail.inMeetingImages.count >= 2) {
//        self.afterMeetingBtn.enabled = YES;
////        self.duringMeetingBtn.cameraButton.enabled = NO;
//    }
//    else {
//        self.afterMeetingBtn.enabled = NO;
////        self.duringMeetingBtn.cameraButton.enabled = YES;
//    }
    //如果会后照片拍够2张，锁定会中会后照片拍照功能
    if (self.meetingDetail.afterMeetingImages.count >= 2) {
        self.afterMeetingBtn.cameraButton.enabled = NO;
        self.duringMeetingBtn.cameraButton.enabled = NO;
    }
    else {
//        self.afterMeetingBtn.cameraButton.enabled = YES;
    }
    
    //如果超过24小时，不允许拍照
    overOneDay = NO;
    BRTMeetingModel *currentMeeting = [[BRTMeetingManager sharedManager] currentMeeting];
    if (currentMeeting.beginTime) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:currentMeeting.beginTime];
        if (time > 86400) {
            overOneDay = YES;
        }
    }
    if (overOneDay) {
        self.beforeMeetingBtn.cameraButton.enabled = NO;
        self.duringMeetingBtn.cameraButton.enabled = NO;
        self.afterMeetingBtn.cameraButton.enabled = NO;
        self.teaBtn.cameraButton.enabled = NO;
        self.carBtn.cameraButton.enabled = NO;
        self.diningBtn.cameraButton.enabled = NO;
        self.othersBtn.cameraButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {             
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClicked:(MeetingDetailButton *)sender {
    self.selectedButton = sender;
    if (sender == self.beforeMeetingBtn) {
        BRTMeetingModel *currentMeeting = [[BRTMeetingManager sharedManager] currentMeeting];
        if (currentMeeting.beginTime == nil) {
            self.alerViewCtrl.message = @"此文件夹为会前照片，请提前5-10分钟拍照，请确认是否拍照！";
            __block MeetingDetailViewController *blockSelf = self;
            [self.alerViewCtrl addActionWithHandler:^{
                [blockSelf performSegueWithIdentifier:@"showImageView" sender:blockSelf.selectedButton];
            }];
            [self.navigationController.view addSubview:self.alerViewCtrl.view];
            return;
        }
    }
    else if (sender == self.afterMeetingBtn) {
        BRTMeetingModel *currentMeeting = [[BRTMeetingManager sharedManager] currentMeeting];
        if (currentMeeting.endTime == nil) {
            self.alerViewCtrl.message = @"此文件夹为会后照片，请在会议结束后拍摄，拍摄完成后会前、会后文件夹将被锁定，请确认是否拍照！";
            __block MeetingDetailViewController *blockSelf = self;
            [self.alerViewCtrl addActionWithHandler:^{
                [blockSelf performSegueWithIdentifier:@"showImageView" sender:blockSelf.selectedButton];
            }];
            [self.navigationController.view addSubview:self.alerViewCtrl.view];
            return;
        }
    }
    [self performSegueWithIdentifier:@"showImageView" sender:sender];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MeetingDetailButton *button = sender;
    if ([segue.identifier isEqualToString:@"showImageView"]) {
        ImageTableViewController *dvc = segue.destinationViewController;
        dvc.title = [button titleForState:UIControlStateNormal];
        dvc.presentsCamera = button.tapsCamera;
        button.tapsCamera = NO;
        dvc.hidesCameraButton = !button.cameraButton.enabled;
        if (sender == self.beforeMeetingBtn) {
            dvc.imageType = BeforeMeetingType;
            dvc.images = self.meetingDetail.beforeMeetingImages;
        }
        else if (sender == self.duringMeetingBtn) {
            dvc.imageType = InMeetingType;
            dvc.images = self.meetingDetail.inMeetingImages;
        }
        else if (sender == self.afterMeetingBtn) {
            dvc.imageType = AfterMeetingType;
            dvc.images = self.meetingDetail.afterMeetingImages;
        }
        else if (sender == self.teaBtn) {
            dvc.imageType = RefreshmentsType;
            dvc.images = self.meetingDetail.teaBreakImages;
        }
        else if (sender == self.carBtn) {
            dvc.imageType = CarsType;
            dvc.images = self.meetingDetail.carServiceImages;
        }
        else if (sender == self.diningBtn) {
            dvc.imageType = MealsType;
            dvc.images = self.meetingDetail.diningImages;
        }
        else if (sender == self.othersBtn) {
            dvc.imageType = OthersType;
            dvc.images = self.meetingDetail.otherImages;
        }
    }
}

@end
