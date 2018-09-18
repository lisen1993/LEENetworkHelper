//
//  LEENetworkCache.h
//  LEENetworkHelper
//
//  Created by 西瓜Team on 2018/9/5.
//  Copyright © 2018年 LEESen. All rights reserved.
//

#import <Foundation/Foundation.h>

//过期提醒
#define LEEDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#pragma mark -- 网络数据缓存类
@interface LEENetworkCache : NSObject

/**
 * 异步缓存网络数据，根据请求的URL 和parameters
 * 做KEY存储数据，这样就能缓存多级页面的数据
 *
 * @pragma httpData   服务端返回的数据
 * @pragma URL        请求URL地址
 * @pragma parameters 请求的参数
 */
+ (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(id)parameters;

/**
 * 根据请求的URL 和parameters 同步取出缓存数据
 *
 * @pragma URL          请求URL地址
 * @pragma parameters   请求的参数
 *
 * @return  缓存的服务器数据
 */
+ (id)httpCacheForURL:(NSString *)URL parameters:(id)parameters;

//获取网络缓存的总大小 bytes（字节）（如需转成M，需除以1024）
+ (NSInteger)getAllHttpCacheSize;

//删除所有缓存数据
+ (void)removeAllHttpCache;

@end
