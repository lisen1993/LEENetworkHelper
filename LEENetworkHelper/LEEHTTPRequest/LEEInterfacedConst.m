//
//  LEEInterfacedConst.m
//  LEENetworkHelper
//
//  Created by 西瓜Team on 2018/9/14.
//  Copyright © 2018年 LEESen. All rights reserved.
//

#import "LEEInterfacedConst.h"

#if DeveloperServer
/** 接口前缀-开发服务器*/
NSString *const kApiPrefix = @"接口服务器请求前缀 如：http://192.168.113.10:8080";
#elif TestServer
/** 接口前缀-测试服务器*/
NSString *const kApiPrefix = @"https://www.baidu.com";
#elif ProductServer
/** 接口前缀-生产服务器*/
NSString *const kApiPrefix = @"https://www.baidu.com";

#endif

NSString *const kLogin = @"login";

NSString *const kExit = @"exit";

@implementation LEEInterfacedConst

@end
