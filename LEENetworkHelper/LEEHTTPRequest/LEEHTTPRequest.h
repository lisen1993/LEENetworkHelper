//
//  LEEHTTPRequest.h
//  LEENetworkHelper
//
//  Created by 西瓜Team on 2018/9/14.
//  Copyright © 2018年 LEESen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    请求成功的Block
    @param response 返回数据
 */
typedef void(^LEERequestSuccess)(id response);

/**
    请求失败的Block
    @param error 返回错误信息
 */
typedef void(^LEERequestFailure)(NSError *error);

@interface LEEHTTPRequest : NSObject

#pragma mark -- 接口网络数据请求

/** 登录 */
+ (NSURLSessionTask *)getLoginWithParameters:(id)parameters success:(LEERequestSuccess)success failure:(LEERequestFailure)failure;


/** 登出 */
+ (NSURLSessionTask *)getExitWithParameters:(id)parameters success:(LEERequestSuccess)success failure:(LEERequestFailure)failure;

@end
