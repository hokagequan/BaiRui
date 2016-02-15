//
//  MeetingDetailButton.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/1/14.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "MeetingDetailButton.h"
#import "Define.h"

@implementation MeetingDetailButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    self.countLabel = [[UILabel alloc] init];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textColor = kAppPinkColor;
    _countLabel.font = [UIFont systemFontOfSize:14];
    _countLabel.textAlignment = NSTextAlignmentRight;
    CGSize btnSize = self.frame.size;
    _countLabel.frame = CGRectMake(btnSize.width-60, btnSize.height-30, 50, 20);
    _countLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_countLabel];
    
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraButton setImage:[UIImage imageNamed:@"img_camera_yes"] forState:UIControlStateNormal];
    [_cameraButton setImage:[UIImage imageNamed:@"img_camera_no"] forState:UIControlStateDisabled];
    _cameraButton.frame = CGRectMake(130, 85, 44, 44);
    [self addSubview:_cameraButton];
    [_cameraButton addTarget:self action:@selector(tapCamera) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    self.cameraButton.enabled = enabled;
}

- (void)tapCamera
{
    self.tapsCamera = YES;
    NSSet *allTargets = [self allTargets];
    for (id target in allTargets) {
        NSArray *actions = [self actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
        for (NSString *action in actions) {
            SEL selector = NSSelectorFromString(action);
            if ([target respondsToSelector:selector]) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [target performSelector:selector withObject:self];
            }
        }
    }
}

@end
