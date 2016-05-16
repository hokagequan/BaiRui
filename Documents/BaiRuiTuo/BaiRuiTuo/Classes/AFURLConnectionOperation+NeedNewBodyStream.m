//
//  AFURLConnectionOperation+NeedNewBodyStream.m
//  BaiRuiTuo
//
//  Created by kingyee on 15/3/23.
//  Copyright (c) 2015年 Kingyee. All rights reserved.
//

#import "AFURLConnectionOperation+NeedNewBodyStream.h"

@implementation AFURLConnectionOperation (NeedNewBodyStream)

- (NSInputStream *)connection:(NSURLConnection __unused *)connection needNewBodyStream:(NSURLRequest *)request {
    if ([request.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
        return [request.HTTPBodyStream copy];
    }
    return nil;
}

@end
