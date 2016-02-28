//
//  ImageScrollViewController.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/15.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "ImageScrollViewController.h"
#import "BRTAlertViewController.h"
#import "SVProgressHUD.h"

#define kImageViewTag 10000

@interface ImageScrollViewController () <UIScrollViewDelegate>
{
    NSInteger currentPage;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSMutableArray *mutableImages;
@property (strong, nonatomic) BRTAlertViewController *alerViewCtrl;

@end

@implementation ImageScrollViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.minImageCount = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    // 2015-04-01, 删除按钮在会后也能用
//    if (self.hidesDeleteButton == NO)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonClicked)];
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    
    self.alerViewCtrl = [[BRTAlertViewController alloc] init];
    
    currentPage = self.imageIndex;
    self.mutableImages = [[NSMutableArray alloc] initWithArray:self.images];
    NSInteger count = self.mutableImages.count;
    self.title = [NSString stringWithFormat:@"%d/%d", (int)currentPage+1, (int)count];
    self.imageViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = kImageViewTag + i;
        UIImage *image = [UIImage imageWithContentsOfFile:self.mutableImages[i]];
        imageView.image = image;//self.mutableImages[i];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:imageView];
        [self.imageViews addObject:imageView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillLayoutSubviews
{
    self.scrollView.frame = self.view.bounds;
    NSInteger count = self.mutableImages.count;
    CGSize contentSize = self.view.bounds.size;
    contentSize.width *= count;
    self.scrollView.contentSize = contentSize;
    
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = self.imageIndex * self.view.bounds.size.width;
    self.scrollView.contentOffset = offset;
    
    for (int i = 0; i < count; i++) {
        UIImageView *imageView = (UIImageView*)[self.scrollView viewWithTag:kImageViewTag + i];
        CGRect ivRect = CGRectZero;
        ivRect.size = self.view.bounds.size;
        ivRect.origin.x = i * ivRect.size.width;
        imageView.frame = ivRect;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

- (void)tapAction
{
    BOOL hidden = self.navigationController.navigationBarHidden;
    self.navigationController.navigationBarHidden = !hidden;
}

- (void)deleteButtonClicked
{
    // 2015-04-02, 会前和会后照片不得少于1张
    if (self.mutableImages.count == self.minImageCount) {
        [SVProgressHUD showInfoWithStatus:@"此文件夹照片不得少于1张"];
        return;
    }
    self.alerViewCtrl.message = @"删除照片后无法恢复，请确认是否删除！";
    __block ImageScrollViewController *blockSelf = self;
    [self.alerViewCtrl addActionWithHandler:^{
        [blockSelf deleteImageAction];
    }];
    [self.navigationController.view addSubview:self.alerViewCtrl.view];
    
}

- (void)deleteImageAction
{
    if (currentPage >= 0 && currentPage < self.mutableImages.count) {
//        UIImage *image = self.mutableImages[currentPage];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBRTImageDidDeleteNotification object:nil userInfo:@{@"Image":self.mutableImages[currentPage]}];
        [self.mutableImages removeObjectAtIndex:currentPage];
        for (NSInteger i = currentPage; i < self.imageViews.count-1; i++) {
            UIImageView *imageView = self.imageViews[i];
            UIImage *image = [UIImage imageWithContentsOfFile:self.mutableImages[i]];
            imageView.image = image;//self.mutableImages[i];
        }
        UIImageView *imageView = [self.imageViews lastObject];
        [imageView removeFromSuperview];
        [self.imageViews removeLastObject];
        
        CGPoint offset = self.scrollView.contentOffset;
        NSInteger count = self.mutableImages.count;
        
        if (count == 0) {
            self.title = [NSString stringWithFormat:@"0/0"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (currentPage < count) {
            self.title = [NSString stringWithFormat:@"%d/%d", (int)currentPage+1, (int)count];
        }
        else {
            currentPage = count - 1;
            self.title = [NSString stringWithFormat:@"%d/%d", (int)currentPage+1, (int)count];
            offset.x = currentPage * self.view.bounds.size.width;
        }
        self.scrollView.contentOffset = offset;
        
        CGSize contentSize = self.scrollView.contentSize;
        contentSize.width = count * self.scrollView.frame.size.width;
        self.scrollView.contentSize = contentSize;
    }
    
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    self.navigationController.navigationBarHidden = YES;
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger page = offsetX/scrollView.frame.size.width;
    currentPage = page;
    
    self.title = [NSString stringWithFormat:@"%d/%d", (int)page+1, (int)self.mutableImages.count];
}

@end
