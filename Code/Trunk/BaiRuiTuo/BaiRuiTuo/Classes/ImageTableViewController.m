//
//  ImageTableViewController.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/15.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "ImageTableViewController.h"
#import "ImageViewCell.h"
#import "ImageScrollViewController.h"
#import "UIImage+Date.h"
#import "UIImage+Resize.h"

@interface ImageTableViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageViewCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic, strong) UIImage *pickedImage;
@property (nonatomic, strong) UIImagePickerController *imagePickerCtrl;

@end

@implementation ImageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BRTMeetingModel *meeting = [[BRTMeetingManager sharedManager] currentMeeting];
    
    if (meeting.beginTime) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:meeting.beginTime];
        if (time > 86400) {
            self.hidesCameraButton = YES;
        }
    }
    if (self.hidesCameraButton == NO) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_btn_camera"] style:UIBarButtonItemStylePlain target:self action:@selector(cameraButtonClicked)];
    }
    
    self.tableView.rowHeight = 130;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDidDelete:) name:kBRTImageDidDeleteNotification object:nil];
    
    self.countLabel.text = [NSString stringWithFormat:@"%@张", @(self.images.count)];
    if (self.presentsCamera) {
        [self cameraButtonClicked];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)imageDidDelete:(NSNotification*)noti
{
    id image = noti.userInfo[@"Image"];
    [self.images removeObject:image];
    NSString *meetingID = [BRTMeetingManager sharedManager].currentMeeting.meetingID;
    [[BRTMeetingManager sharedManager] deleteImage:image withMeetingID:meetingID];
    self.countLabel.text = [NSString stringWithFormat:@"%@张", @(self.images.count)];
    [self.tableView reloadData];
}

- (void)cameraButtonClicked
{
#if TARGET_IPHONE_SIMULATOR
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePickerCtrl = [[UIImagePickerController alloc] init];
        imagePickerCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerCtrl.delegate = self;
        [self presentViewController:imagePickerCtrl animated:YES completion:nil];
    }
#else
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self performSelector:@selector(showImagePicker) withObject:nil afterDelay:0.3];
    }
#endif
}

- (void)showImagePicker
{
    UIImagePickerController *imagePickerCtrl = [[UIImagePickerController alloc] init];
    imagePickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerCtrl.delegate = self;
    self.imagePickerCtrl = imagePickerCtrl;
    [self presentViewController:imagePickerCtrl animated:YES completion:nil];
}

#pragma mark - Image picker controller delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = nil;
    if (picker.allowsEditing) {
        image = [info valueForKey:UIImagePickerControllerEditedImage];
    }
    else {
        image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    NSDate *date = [NSDate date];
    //给图片添加时间信息
    image = [image imageWithDate:date];
    //减小图片尺寸
    image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(1024, 768)];
//    self.pickedImage = image;
    [self dismissViewControllerAnimated:YES completion:^{
        NSData *imageData = nil;
        //    imageData = UIImagePNGRepresentation(image);
        //    imageData = UIImageJPEGRepresentation(image, 1);
        //    imageData = UIImageJPEGRepresentation(image, 0);
        imageData = UIImageJPEGRepresentation(image, 0.1);
        NSString *imageFile = [[BRTMeetingManager sharedManager] writeImageData:imageData withImageType:self.imageType];
        [self.images addObject:imageFile];
        self.countLabel.text = [NSString stringWithFormat:@"%@张", @(self.images.count)];
        [self.tableView reloadData];
        if (self.imageType == BeforeMeetingType) {
            BRTMeetingModel *meeting = [[BRTMeetingManager sharedManager] currentMeeting];
            // QCW FIX 1.4
            if (meeting.endTime == nil) {
                meeting.endTime = date;
                int time = [date timeIntervalSince1970];
                [[BRTMeetingManager sharedManager] updateValue:@(time) forKey:kBRTMeetingEndTimeKey withMeetingID:meeting.meetingID];
            }
            
//            if (meeting.beginTime == nil) {
//                meeting.beginTime = date;
//                int time = [date timeIntervalSince1970];
//                [[BRTMeetingManager sharedManager] updateValue:@(time) forKey:kBRTMeetingBeginTimeKey withMeetingID:meeting.meetingID];
//            }
        }
        if (self.imageType == AfterMeetingType) {
            BRTMeetingModel *meeting = [[BRTMeetingManager sharedManager] currentMeeting];
            if (meeting.endTime == nil) {
                meeting.endTime = date;
                int time = [date timeIntervalSince1970];
                [[BRTMeetingManager sharedManager] updateValue:@(time) forKey:kBRTMeetingEndTimeKey withMeetingID:meeting.meetingID];
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image view cell delegate
- (void)imageViewCell:(ImageViewCell*)cell didSelectedImageAtIndex:(NSInteger)index
{
    NSInteger imageIndex = cell.row * kCellImageViewCount + index;
    ImageScrollViewController *imageScrollVC = [[ImageScrollViewController alloc] init];
    imageScrollVC.imageIndex = imageIndex;
    imageScrollVC.images = self.images;
//    imageScrollVC.hidesDeleteButton = self.hidesCameraButton;
    if (self.imageType == BeforeMeetingType || self.imageType == AfterMeetingType) {
        imageScrollVC.minImageCount = 1;
    }
    [self.navigationController pushViewController:imageScrollVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rowCount = (NSInteger)ceil(self.images.count*1.0/kCellImageViewCount);
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.backgroundView = nil;
    cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    cell.row = indexPath.row;
    cell.delegate = self;
    for (int i = 0; i < kCellImageViewCount; i++) {
        NSInteger imageIndex = indexPath.row*kCellImageViewCount + i;
        if (imageIndex < self.images.count) {
            UIImage *image = [UIImage imageWithContentsOfFile:self.images[imageIndex]];
            [(UIImageView*)cell.imageViews[i] setImage:image];
        }
        else {
            [(UIImageView*)cell.imageViews[i] setImage:nil];
        }
    }
    
    return cell;
}

#pragma mark - fix image rotation
- (UIImage *)fixImageRotation:(UIImage *)image{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    
    
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage); //when I use instruments it shows that My VM is because of this
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);//also this line in Instruments
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

@end
