//
//  ViewController.m
//  LEENetworkHelper
//
//  Created by 西瓜Team on 2018/9/5.
//  Copyright © 2018年 LEESen. All rights reserved.
//

#import "ViewController.h"
#import "LEENetworkHelper.h"
#import "LEEHTTPRequest.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //开启日志打印
    [LEENetworkHelper openLog];
    
    //获取缓存
    NSLog(@"%.1f",[LEENetworkCache getAllHttpCacheSize]/1023.f);
    
    //清理缓存 [LEENetworkCache removeAllHttpCache];
    
    //实时监控网络
    [self monitorNetworkStatus];
}

#pragma mark -- 监测实时网络状态
- (void)monitorNetworkStatus
{
    [LEENetworkHelper networkStatusWithBlock:^(LEENetworkStatusType status) {
        switch (status) {
            case LEENetworkStatusUnknow:
                NSLog(@"未知网络");
                break;
            case LEENetworkStatusNotReachable:
                NSLog(@"无网络");
                break;
            case LEENetworkStatusReachableViaWWAN:
                NSLog(@"数据网络");
                break;
            case LEENetworkStatusReachableViaWIFI:
                NSLog(@"WiFi网络");
                break;
            default:
                break;
        }
    }];
}


/**
 *  json转字符串
 */
- (NSString *)jsonToString:(NSDictionary *)dic
{
    if(!dic){
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


@end
