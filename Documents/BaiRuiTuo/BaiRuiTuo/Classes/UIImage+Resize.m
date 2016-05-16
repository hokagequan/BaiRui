//
//  UIImage+Resize.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/4/27.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    if (image == nil) {
        return nil;
    }
    CGFloat ws = newSize.width/image.size.width;
    CGFloat hs = newSize.height/image.size.height;
    
    if (ws > hs) {
        ws = hs/ws;
        hs = 1.0;
    } else {
        hs = ws/hs;
        ws = 1.0;
    }
    CGSize size = CGSizeMake(newSize.width*ws, newSize.height*hs);
    
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
