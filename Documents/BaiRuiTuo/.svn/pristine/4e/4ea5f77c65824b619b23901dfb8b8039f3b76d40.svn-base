//
//  ImageViewCell.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/15.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "ImageViewCell.h"

@implementation ImageViewCell

- (void)awakeFromNib {
    // Initialization code
    for (UIImageView *imageView in self.imageViews) {
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)imageTapped:(UITapGestureRecognizer*)tapGR
{
    UIImageView *imageView = (UIImageView *)tapGR.view;
    if (imageView.image) {
        NSInteger index = imageView.tag - 101;
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewCell:didSelectedImageAtIndex:)]) {
            [self.delegate imageViewCell:self didSelectedImageAtIndex:index];
        }
    }
}

@end
