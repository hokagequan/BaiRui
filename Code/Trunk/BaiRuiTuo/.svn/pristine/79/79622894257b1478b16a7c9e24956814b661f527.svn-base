//
//  UIImage+Date.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/28.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "UIImage+Date.h"

@implementation UIImage (Date)

- (UIImage*)imageWithDate:(NSDate*)date
{
    
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"yyyy.MM.dd HH:mm";
    NSString *dateString = [dateFmt stringFromDate:date];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = self;
    CGRect rect = CGRectZero;
    rect.size = self.size;
    imageView.frame = rect;
    
    CGFloat scale = rect.size.width/1024;
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.text = dateString;
    label.textColor = [UIColor yellowColor];
    label.font = [UIFont boldSystemFontOfSize:34*scale];
    [label sizeToFit];
    CGRect labelRect = label.frame;
    labelRect.origin.x = rect.size.width - labelRect.size.width - 30;
    labelRect.origin.y = rect.size.height - labelRect.size.height - 30;
    label.frame = labelRect;
    [imageView addSubview:label];
    
    UIGraphicsBeginImageContext(self.size);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
