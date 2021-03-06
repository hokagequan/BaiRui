//
//  MeetingViewController.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/13.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "MeetingViewController.h"
#import "Define.h"
#import "MeetingViewCell.h"
#import "BRTProgressViewController.h"
#import "BRTAlertViewController.h"
#import "BRTMeetingManager.h"
#import "MeetingDetailViewController.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "AFNetworking.h"
#import "BaiduMobStat.h"

#define kLeftButtonTag 100000
#define kCenterButtonTag 200000
#define kRightButtonTag 300000

@interface MeetingViewController () <UITableViewDataSource, UITableViewDelegate, MeetingViewCellDelegate>
{
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *meetings;
@property (nonatomic, strong) BRTProgressViewController *progressViewCtrl;
@property (strong, nonatomic) BRTAlertViewController *alerViewCtrl;

@end

@implementation MeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // QCW 1.4 FIX
    self.meetingType = AllMeeting;
    self.title = @"会议列表";
    self.navigationController.navigationBarHidden = NO;
    
    self.alerViewCtrl = [[BRTAlertViewController alloc] init];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MeetingCell"];
    // Do any additional setup after loading the view.
    self.tableView.rowHeight = 44.0f;
    
    NSMutableArray *array = [[BRTMeetingManager sharedManager] loadMeetingList:self.meetingType];
    // QCW 1.4 FIX
    self.meetings = [self filterdArray:array];
    
    // FIXME: Test
    [self loadAllMeeting];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [[BRTMeetingManager sharedManager] uploadMeetingRecords];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// QCW 1.4 FIX
- (NSMutableArray *)filterdArray:(NSMutableArray *)array {
    [array filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        BRTMeetingModel *meeting = (BRTMeetingModel *)evaluatedObject;
        return ([meeting.meetingState integerValue] != CancelByAppState && [meeting.meetingState integerValue] != ExpiredState && [meeting.meetingState integerValue] != CancelByServerState);
    }]];
    
    return array;
}

- (void)showMeetingDetail:(BRTMeetingModel*)meeting {
    [self performSegueWithIdentifier:@"showMeetingDetail" sender:meeting];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMeetingDetail"]) {
        MeetingDetailViewController *dvc = segue.destinationViewController;
        dvc.meetingDetail = [(BRTMeetingModel*)sender meetingDetail];
        [[BRTMeetingManager sharedManager] setCurrentMeeting:sender];
    }
}

- (void)uploadMeeting:(BRTMeetingModel*)meeting;
{
    self.progressViewCtrl = [[BRTProgressViewController alloc] init];
    [self.navigationController.view addSubview:self.progressViewCtrl.view];
    BRTMeetingManager *meetingMan = [BRTMeetingManager sharedManager];
    __block MeetingViewController *blockSelf = self;
    [meetingMan uploadMeeting:meeting success:^(id JSON) {
        if (JSON && [JSON isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = JSON;
            NSString *result = [dict objectForKey:@"Result"];
            if ([result isEqualToString:@"Fail"]) {
                NSString *message = [dict objectForKey:@"Message"];
                [blockSelf.progressViewCtrl dismissWithMessage:@"同步失败" animated:NO];
                [SVProgressHUD showErrorWithStatus:message];
            }
            else {
                [blockSelf uploadSuccess:meeting];
                [blockSelf.progressViewCtrl dismissWithMessage:@"同步完成" animated:YES];
            }
        }
    } failure:^(NSError *error) {
        NSString *errMsg = [NSString stringWithFormat:@"%d:%@", (int)error.code, error.localizedDescription];
        [[BaiduMobStat defaultStat] logEvent:@"1" eventLabel:errMsg];
        [blockSelf.progressViewCtrl dismissWithMessage:@"同步失败" animated:NO];
        if (error.code == NSURLErrorCannotFindHost) {
            NSString *msg = [error.localizedDescription stringByAppendingString:@"请开启VPN"];
            [SVProgressHUD showErrorWithStatus:msg];
        }
        else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void)uploadSuccess:(BRTMeetingModel*)meeting
{
    meeting.meetingState = @(UploadedState);
    NSDate *date = [NSDate date];
    meeting.uploadTime = date;
    int time = [date timeIntervalSince1970];
    [[BRTMeetingManager sharedManager] updateValue:@(UploadedState) forKey:kBRTMeetingStateKey withMeetingID:meeting.meetingID];
    [[BRTMeetingManager sharedManager] updateValue:@(time) forKey:kBRTMeetingUploadTimeKey withMeetingID:meeting.meetingID];
    [self.tableView reloadData];
}

//获取会议信息
- (void)loadAllMeeting
{
//    static BOOL hasGotten = NO;
//    if (hasGotten == YES) {
//        return;
//    }
    
    // FIXME: Test
//    NSString *pathtemp = NSTemporaryDirectory();
//    [[BRTMeetingManager sharedManager] createDatabase];
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"kk" ofType:@"plist"];
//    NSDictionary *sourceDict = [NSDictionary dictionaryWithContentsOfFile:path];
//    NSString *dataString = sourceDict[@"string"];
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
//    NSArray *array = [dict objectForKey:@"Arguments"];
//    [[BRTMeetingManager sharedManager] updateMeetingList:array];
//    NSMutableArray *newArray = [[BRTMeetingManager sharedManager] loadMeetingList:self.meetingType];
//    // QCW 1.4 FIX
//    self.meetings = [self filterdArray:newArray];
//    [self.tableView reloadData];
//    
//    return;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:kBRTUsernameKey];
    NSString *urlString = [kBRTOPERAServerURL stringByAppendingPathComponent:@"Event.aspx"];
    //    NSDictionary *parameters = @{@"RequesterCWID": username, @"EventType":@(0)};
    urlString = [urlString stringByAppendingFormat:@"?RequesterCWID=%@&EventType=%@", username, @""];
    
    //EventType活动类型:1科室会；2院内会；10城市会；不传，所有类型。
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    __block BRTMeetingManager *meetingMan = [BRTMeetingManager sharedManager];
    __block MeetingViewController *blockSelf = self;
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = responseObject;
            NSString *result = [dict objectForKey:@"Result"];
            if ([result isEqualToString:@"Fail"]) {
                NSString *message = [dict objectForKey:@"Message"];
                [SVProgressHUD showErrorWithStatus:[message chineseString]];
            }
            else {
                [SVProgressHUD dismiss];
                NSArray *array = [dict objectForKey:@"Arguments"];
                [meetingMan updateMeetingList:array];
                NSMutableArray *newArray = [meetingMan loadMeetingList:blockSelf.meetingType];
                // QCW 1.4 FIX
                blockSelf.meetings = [self filterdArray:newArray];
                [blockSelf.tableView reloadData];
//                hasGotten = YES;
            }
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"获取失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == NSURLErrorCannotFindHost) {
            NSString *msg = [error.localizedDescription stringByAppendingString:@"请开启VPN"];
            [SVProgressHUD showErrorWithStatus:msg];
        }
        else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
    [SVProgressHUD showWithStatus:@"正在获取会议信息"];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.meetings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MeetingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingCell" forIndexPath:indexPath];
    cell.backgroundView = nil;
    cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    NSInteger row = indexPath.row;
    
    cell.leftButton.tag = kLeftButtonTag + row;
    cell.startButton.tag = kLeftButtonTag + row;
    cell.centerButton.tag = kCenterButtonTag + row;
    cell.rightButton.tag = kRightButtonTag + row;
    cell.delegate = self;
    
    // QCW 1.4 Fix
    BRTMeetingModel *meeting = self.meetings[row];
    NSString *typeString = meeting.meetingType;
//    switch (self.meetingType) {
//        case BRTOfficeMeeting:
//            typeString = @"科室会";
//            break;
//        case BRTHospitalMeeting:
//            typeString = @"院内会";
//            break;
//        case BRTCityMeeting:
//            typeString = @"城市会";
//            break;
//        default:
//            break;
//    }
    cell.typeLabel.text = typeString;
    cell.numberLabel.text = meeting.meetingID;
    cell.dateLabel.text = meeting.meetingTime;
    cell.nameLabel.text = meeting.meetingName;
    cell.officeLabel.text = meeting.meetingOffice;
    cell.state = [meeting.meetingState intValue];
    cell.detail = meeting.meetingDetail;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Meeting view cell delegate
- (void)meetingViewCell:(MeetingViewCell *)cell didClickedButtonWithTag:(NSInteger)tag
{
    NSInteger row;
    NSInteger btnType = 0;
    if (tag < kLeftButtonTag) {
        row = -1;
    }
    else if (tag < kCenterButtonTag) {
        row = tag - kLeftButtonTag;
        btnType = 1;
    }
    else if (tag < kRightButtonTag) {
        row = tag - kCenterButtonTag;
        btnType = 2;
    }
    else {
        row = tag - kRightButtonTag;
        btnType = 3;
    }
    if (row < 0 || row >= self.meetings.count) {
        return;
    }
    BRTMeetingModel *meetingModel = self.meetings[row];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"yyyy-MM-dd";
    NSDate *meetingDate = [dateFmt dateFromString:meetingModel.meetingTime];
    NSDate *today = [NSDate date];
    NSTimeInterval oneDay = 60 * 60 * 24;
    int dayOffset = ceil([meetingDate timeIntervalSinceDate:today]/oneDay);
    
    NSInteger state = [meetingModel.meetingState integerValue];
    if (state == BeforeMeetingState) {
        // QCW 1.4 fix
//        if (dayOffset >= 7) {
//            [SVProgressHUD showImage:nil status:@"时间未到，不能开始会议"];
//        }
//        else {
            // QCW FIX 1.4
            NSDate *date = [NSDate date];
            meetingModel.beginTime = date;
            int time = [date timeIntervalSince1970];
            [[BRTMeetingManager sharedManager] updateValue:@(time) forKey:kBRTMeetingBeginTimeKey withMeetingID:meetingModel.meetingID];
            
            meetingModel.meetingState = @(InMeetingState);
            [[BRTMeetingManager sharedManager] updateValue:@(InMeetingState) forKey:kBRTMeetingStateKey withMeetingID:meetingModel.meetingID];
            [self.tableView reloadData];
            [self showMeetingDetail:meetingModel];
//        }
    }
    else if (state == InMeetingState) {
        if (btnType == 2) {
            [self showMeetingDetail:meetingModel];
        }
    }
    else if (state == AfterMeetingState || state == UploadedState) {
        if (btnType == 1) {
            // 2015-04-02, 同步时照片数量不作限制
            BRTMeetingDetailModel *meetingDetail = meetingModel.meetingDetail;
            if (meetingDetail.beforeMeetingImages.count < 1) {
                [SVProgressHUD showErrorWithStatus:@"照片少于1张，无法同步"];
                return;
            }
//            else if (meetingDetail.inMeetingImages.count < 1) {
//                [SVProgressHUD showErrorWithStatus:@"照片少于1张，无法同步"];
//                return;
//            }
//            else if (meetingDetail.afterMeetingImages.count < 1) {
//                [SVProgressHUD showErrorWithStatus:@"照片少于1张，无法同步"];
//                return;
//            }
            // 2015-04-02, 同步时不验证登录信息
//            __block MeetingViewController *blockSelf = self;
//            [SVProgressHUD show];
//            [LoginViewController checkInBackgroundSuccess:^{
//                [SVProgressHUD dismiss];
//                [blockSelf uploadMeeting:meetingModel];
//            } failure:^{
//                [SVProgressHUD dismiss];
//                [blockSelf.navigationController popToRootViewControllerAnimated:YES];
//            }];
            [self uploadMeeting:meetingModel];
        }
        else if (btnType == 2 || btnType == 3) {
            [self showMeetingDetail:meetingModel];
        }
    }
}

@end
