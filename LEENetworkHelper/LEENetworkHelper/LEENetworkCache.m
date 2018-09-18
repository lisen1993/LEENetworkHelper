//
//  LEENetworkCache.m
//  LEENetworkHelper
//
//  Created by 西瓜Team on 2018/9/5.
//  Copyright © 2018年 LEESen. All rights reserved.
//

#import "LEENetworkCache.h"
#import "YYCache.h"

static NSString *const kLEENetworkResponseCache = @"kLEENetworkResponseCache";

@implementation LEENetworkCache

static YYCache *_dataCache;

+ (void)initialize
{
    _dataCache = [YYCache cacheWithName:kLEENetworkResponseCache];
}

+ (void)setHttpCache:(id)httpData URL:(NSString *)URL parameters:(id)parameters
{
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    
    //异步缓存，不会阻塞主线程
    [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
}

+ (id)httpCacheForURL:(NSString *)URL parameters:(id)parameters
{
    NSString *cacheKey = [self cacheKeyWithURL:URL parameters:parameters];
    return [_dataCache objectForKey:cacheKey];
}

+ (NSInteger)getAllHttpCacheSize
{
    return [_dataCache.diskCache totalCost];
}

+ (void)removeAllHttpCache
{
    [_dataCache.diskCache removeAllObjects];
}

+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters
{
    if (!parameters || parameters.count == 0) {
        return URL;
    }
    
    //将参数字典转换为字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc]initWithData:stringData encoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"%@%@",URL,paraString];
}

@end
