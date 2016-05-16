//
//  CustomObjectUtil.h
//  com.eading.wireless
//
//  Created by Q on 14/12/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CustomObjectUtil : NSObject

+ (void)customObject:(NSArray *)views
    backgroundColor:(UIColor *)backgroundColor
         borderWith:(CGFloat)borderWidth
        borderColor:(UIColor *)borderColor
             corner:(CGFloat)corner;

+ (void)customTabbarItem:(NSArray *)items titleColor:(UIColor *)color font:(UIFont *)font state:(UIControlState)state;

+ (void)customNavigationBarColor:(UIColor *)naviColor itemColor:(UIColor *)itemColor;
+ (void)customNavigationBarTitleFont:(UIFont *)font color:(UIColor *)color;
+ (void)customHideNavigationBarBackTitle;

+ (void)customNavigation:(UINavigationController *)navi barColor:(UIColor *)barColor itemColor:(UIColor *)itemColor;
+ (void)customNavigation:(UINavigationController *)navi titleFont:(UIFont *)font color:(UIColor *)color;
+ (void)customHideNavigationBarBackTitle:(UINavigationController *)navi;
+ (void)customDefaultNavigation:(UINavigationController *)navi;

@end
