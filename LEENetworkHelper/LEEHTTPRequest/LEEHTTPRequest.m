//
//  LEEHTTPRequest.m
//  LEENetworkHelper
//
//  Created by 西瓜Team on 2018/9/14.
//  Copyright © 2018年 LEESen. All rights reserved.
//

#import "LEEHTTPRequest.h"
#import "LEEInterfacedConst.h"
#import "LEENetworkHelper.h"

@implementation LEEHTTPRequest



/** 登录 */
+ (NSURLSessionTask *)getLoginWithParameters:(id)parameters success:(LEERequestSuccess)success failure:(LEERequestFailure)failure
{
    NSString *URL = [NSString stringWithFormat:@"%@%@",kApiPrefix,kLogin];
    return [self requestWithURL:URL parameters:parameters success:success failure:failure];
}

/** 登出 */
+ (NSURLSessionTask *)getExitWithParameters:(id)parameters success:(LEERequestSuccess)success failure:(LEERequestFailure)failure
{
    NSString *URL = [NSString stringWithFormat:@"%@%@",kApiPrefix,kExit];
    
    return [self requestWithURL:URL parameters:parameters success:success failure:failure];
}

/**
 配置好LEENetworkHelper各项请求参数，封装成公共方法，给一下方法调用，
 相比在项目中单个分散的使用LEENetworkHelper/其他网络框架请求，降低耦合
 后期切换网络请求框架方便快捷
 */
#pragma mark -- 请求的公共方法
//post请求
+ (NSURLSessionTask *)requestWithURL:(NSString *)URL parameters:(id)parameters success:(LEERequestSuccess)success failure:(LEERequestFailure)failure
{
    //在请求前统一配置请求的相关参数，设置请求头，请求参数的格式，返回数据的格式 等
    
    //设置请求头
    [LEENetworkHelper setValue:@"iosApp" forHttpHeaderField:@"fromType"];
    //设置请求参数格式为string
    [LEENetworkHelper setQueryStringSerializationWithParameters:parameters];
    //发起请求
    return [LEENetworkHelper POST:URL parameters:parameters success:^(id responseObject) {
        //在这里可以根据项目自定义一些重复操作，例如：页面加载的等待效果，提醒弹窗等。。。
        success(responseObject);
    } failure:^(NSError *error) {
        //在这里可以根据项目自定义一些重复操作，例如：页面加载的等待效果，提醒弹窗等。。。
        failure(error);
    }];
}


@end
