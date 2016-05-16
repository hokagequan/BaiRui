//
//  NSString+Chinese.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/2/9.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "NSString+Chinese.h"

@implementation NSString (Chinese)

- (NSString*)chineseString
{
//    NSString *string = [self stringByReplacingOccurrencesOfString:@"[a-zA-Z.,\\s]*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
//    if ([string isEqualToString:@""]) {
//        return self;
//    }
//    return string;
    NSRange range = [self rangeOfString:@"。"];
    if (range.location != NSNotFound) {
        return [self substringToIndex:range.location];
    }
    else {
        return self;
    }
}

@end
