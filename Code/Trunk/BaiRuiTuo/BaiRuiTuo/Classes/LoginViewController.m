//
//  LoginViewController.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/13.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "LoginViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Define.h"

#define TEST

@interface LoginViewController ()
{
}

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *rememberButton;

- (IBAction)loginButtonClicked:(UIButton*)sender;
- (IBAction)rememberButtonClicked:(UIButton*)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self logined]) {
        [self performSegueWithIdentifier:@"showRootView" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self loadData];
}

- (void)loadData
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL remembered = [ud boolForKey:kBRTRemberPasswordKey];
    self.rememberButton.selected = remembered;
    NSString *username = [ud stringForKey:kBRTUsernameKey];
    NSString *password = [ud stringForKey:kBRTPasswordKey];
    self.usernameField.text = username;
    self.passwordField.text = password;
    if (username) {
#ifndef DEBUG
        self.usernameField.enabled = NO;
#endif
    }
    else {
        self.usernameField.enabled = YES;
    }
}

+ (void)logout
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:kBRTPasswordKey];
    [ud synchronize];
}

- (BOOL)logined {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:kBRTUsernameKey];
    NSString *password = [ud stringForKey:kBRTPasswordKey];
    if (username && password) {
        return YES;
    }
    return NO;
}

static BOOL checked = NO;
+ (void)checkInBackgroundSuccess:(void (^)(void))success
                         failure:(void (^)(void))failure
{
#if TARGET_IPHONE_SIMULATOR
    checked = YES;
#endif
#ifdef TEST
    checked = YES;
#endif
    if (checked) {
        success();
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud stringForKey:kBRTUsernameKey];
    NSString *password = [ud stringForKey:kBRTPasswordKey];
    if (username && password) {
        NSString *urlString = [kBRTOPERAServerURL stringByAppendingPathComponent:@"Login.aspx"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"CWID": username, @"Password":password};
        [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = responseObject;
                NSString *result = [dict objectForKey:@"Result"];
                if ([result isEqualToString:@"Success"]) {
                    success();
                    checked = YES;
                }
                else {
//                    NSString *message = [dict objectForKey:@"Message"];
                    [SVProgressHUD showErrorWithStatus:@"登录信息错误，请重新登录"];
                    failure();
                }
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"登录信息错误，请重新登录"];
                failure();
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // 2015-04-02,没网或没开VPN忽略验证
//            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//            failure();
            success();
        }];
    }
    else {
        //应用启动后需登录才能进入，如果没填密码，则已经登录过了，无需验证。
        success();
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

- (IBAction)loginButtonClicked:(UIButton*)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    if (username.length == 0) {
        [SVProgressHUD showImage:nil status:@"请输入用户名"];
        return;
    }
    if (password.length == 0) {
        [SVProgressHUD showImage:nil status:@"请输入密码"];
        return;
    }
    
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    [self loginWithUsername:username password:password];
}

- (void)loginWithUsername:(NSString*)username password:(NSString*)password
{
//#if TARGET_IPHONE_SIMULATOR
#ifdef TEST
    [self loginSuccessWithUsername:username password:password];
    return;
#endif
    NSString *urlString = [kBRTOPERAServerURL stringByAppendingPathComponent:@"Login.aspx"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"CWID": username, @"Password":password};
    __block LoginViewController *blockSelf = self;
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = responseObject;
            NSString *result = [dict objectForKey:@"Result"];
            if ([result isEqualToString:@"Success"]) {
                [SVProgressHUD dismiss];
                [blockSelf loginSuccessWithUsername:username password:password];
            }
            else {
                NSString *message = [dict objectForKey:@"Message"];
                [SVProgressHUD showErrorWithStatus:[message chineseString]];
            }
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"登录失败"];
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
    [SVProgressHUD show];
}

- (void)loginSuccessWithUsername:(NSString*)username password:(NSString*)password
{
    checked = YES;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:username forKey:kBRTUsernameKey];
    if (self.rememberButton.selected) {
        [ud setObject:password forKey:kBRTPasswordKey];
    }
    else {
        [ud removeObjectForKey:kBRTPasswordKey];
    }
    [ud synchronize];
    if (self.navigationController.topViewController == self) {
        [self performSegueWithIdentifier:@"showRootView" sender:nil];
    }
}

- (IBAction)rememberButtonClicked:(UIButton*)sender {
    sender.selected = !sender.selected;
    BOOL selected = sender.selected;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:selected forKey:kBRTRemberPasswordKey];
    [ud synchronize];
}

@end
