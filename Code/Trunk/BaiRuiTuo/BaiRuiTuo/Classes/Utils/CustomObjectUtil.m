//
//  CustomObjectUtil.m
//  com.eading.wireless
//
//  Created by Q on 14/12/15.
//
//

#import "CustomObjectUtil.h"

@implementation CustomObjectUtil

+ (void)customObject:(NSArray *)views backgroundColor:(UIColor *)backgroundColor borderWith:(CGFloat)borderWidth borderColor:(UIColor *)borderColor corner:(CGFloat)corner {
    for (UIView *view in views) {
        view.backgroundColor = backgroundColor;
        view.layer.borderWidth = borderWidth;
        view.layer.borderColor = borderColor.CGColor;
        view.layer.cornerRadius = corner;
        view.layer.masksToBounds = YES;
    }
}

+ (void)customTabbarItem:(NSArray *)items titleColor:(UIColor *)color font:(UIFont *)font state:(UIControlState)state {
    for (UITabBarItem *item in items) {
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: font} forState:state];
    }
}

+ (void)customNavigationBarColor:(UIColor *)naviColor itemColor:(UIColor *)itemColor {
    if ([naviColor isEqual:[UIColor clearColor]]) {
        if ([[UINavigationBar appearance] respondsToSelector:@selector(setTranslucent:)]) {
            [[UINavigationBar appearance] setTranslucent:YES];
        }
        [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[UIImage new]];
        [[UINavigationBar appearance] setBackgroundColor:[UIColor clearColor]];
    }
    else {
        if ([[UINavigationBar appearance] respondsToSelector:@selector(setTranslucent:)]) {
            [[UINavigationBar appearance] setTranslucent:YES];
        }
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:nil];
        [[UINavigationBar appearance] setBarTintColor:naviColor];
    }
    [[UINavigationBar appearance] setTintColor:itemColor];
//    [[UINavigationBar appearance] setBarTintColor:naviColor];
//    [[UINavigationBar appearance] setTintColor:itemColor];
//    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: itemColor}
//                                                forState:UIControlStateNormal];
    
    [self customNavigationBarTitleFont:[UIFont systemFontOfSize:16.0] color:itemColor];
}

+ (void)customNavigationBarTitleFont:(UIFont *)font color:(UIColor *)color {
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: font}];
}

+ (void)customHideNavigationBarBackTitle {
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}

+ (void)customNavigation:(UINavigationController *)navi barColor:(UIColor *)barColor itemColor:(UIColor *)itemColor {
    if ([barColor isEqual:[UIColor clearColor]]) {
        [navi.navigationBar setTranslucent:YES];
        [navi.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [navi.navigationBar setShadowImage:[UIImage new]];
        [navi.navigationBar setBackgroundColor:[UIColor clearColor]];
        [navi.navigationBar setBarTintColor:[UIColor clearColor]];
    }
    else {
        [navi.navigationBar setTranslucent:YES];
        [navi.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navi.navigationBar setShadowImage:nil];
        [navi.navigationBar setBarTintColor:barColor];
    }
    [navi.navigationBar setTintColor:itemColor];
    [navi.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: itemColor} forState:UIControlStateNormal];
}

+ (void)customNavigation:(UINavigationController *)navi titleFont:(UIFont *)font color:(UIColor *)color {
    [navi.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: font}];
}

+ (void)customHideNavigationBarBackTitle:(UINavigationController *)navi {
    [navi.navigationItem.backBarButtonItem setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}

+ (void)customDefaultNavigation:(UINavigationController *)navi {
    [self customNavigation:navi barColor:[UIColor whiteColor] itemColor:[UIColor redColor]];
    [self customNavigation:navi titleFont:[UIFont systemFontOfSize:16.0] color:[UIColor redColor]];
    [self customHideNavigationBarBackTitle];
}

@end
