//
//  ImageViewCell.h
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/15.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageViewCellDelegate;

#define kCellImageViewCount 7

@interface ImageViewCell : UITableViewCell

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (nonatomic, assign) id <ImageViewCellDelegate> delegate;
@property (nonatomic, assign) NSInteger row;

@end

@protocol ImageViewCellDelegate <NSObject>

- (void)imageViewCell:(ImageViewCell*)cell didSelectedImageAtIndex:(NSInteger)index;

@end
