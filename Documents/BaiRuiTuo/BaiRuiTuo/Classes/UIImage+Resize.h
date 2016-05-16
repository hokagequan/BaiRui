//
//  UIImage+Resize.h
//  BaiRuiTuo
//
//  Created by kingyee on 15/4/27.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
