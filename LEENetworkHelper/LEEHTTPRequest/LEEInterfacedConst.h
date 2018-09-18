//
//  LEEInterfacedConst.h
//  LEENetworkHelper
//
//  Created by 西瓜Team on 2018/9/14.
//  Copyright © 2018年 LEESen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 
    将项目的所有接口写在这里，方便统一管理，降低耦合
 
    通过宏定义来切换当前的服务器类型
    将要切换的服务器类型宏后面设置为真（即>0）,其余为假（设置为0）
 
    如：当前服务器状态为测试服务器
 */
#define DevelopServer 0
#define TestServer    1
#define ProductServer 0

/** 接口前缀-开发服务器 */
UIKIT_EXTERN NSString *const kApiPrefix;

#pragma mark -- 详细接口地址（即URL后缀拼接）

/** 登录 */
UIKIT_EXTERN NSString *const kLogin;

/** 退出 */
UIKIT_EXTERN NSString *const kExit;

@interface LEEInterfacedConst : NSObject
@end
