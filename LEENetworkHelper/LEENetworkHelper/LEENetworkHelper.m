//
//  LEENetworkHelper.m
//  LEENetworkHelper
//
//  Created by 西瓜Team on 2018/9/5.
//  Copyright © 2018年 LEESen. All rights reserved.
//

#import "LEENetworkHelper.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

#ifdef DEBUG
#define LEELog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define LEELog(...)
#endif

#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

@implementation LEENetworkHelper

/// 是否已开启日志打印
static BOOL _isOpenLog;

static NSMutableArray *_allSessionTask;

static AFHTTPSessionManager *_sessionManager;

#pragma mark -- 开始监听网络
+ (void)networkStatusWithBlock:(LEENetworkStatus)networkStatus
{
    [[AFNetworkReachabilityManager sharedManager]
     setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
         switch (status) {
             case AFNetworkReachabilityStatusUnknown:
                 networkStatus ? networkStatus(LEENetworkStatusUnknow) : nil;
                 if (_isOpenLog) {
                     LEELog(@"未知网络");
                 }
                 break;
             case AFNetworkReachabilityStatusNotReachable:
                 networkStatus ? networkStatus(LEENetworkStatusNotReachable) : nil;
                 if (_isOpenLog) {
                     LEELog(@"无网络");
                 }
                 break;
             case AFNetworkReachabilityStatusReachableViaWWAN:
                 networkStatus ? networkStatus(LEENetworkStatusReachableViaWWAN) : nil;
                 if (_isOpenLog) {
                     LEELog(@"手机无线网络");
                 }
                 break;
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 networkStatus ? networkStatus(LEENetworkStatusReachableViaWIFI) : nil;
                 if (_isOpenLog) {
                     LEELog(@"WiFi网络");
                 }
                 break;
             default:
                 break;
         }
    }];
}

+ (BOOL)isNetwork
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL)isWIFINetwork
{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

+ (BOOL)isWWANNetwork
{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

+ (void)openLog
{
    _isOpenLog = YES;
}

+ (void)closeLog
{
    _isOpenLog = NO;
}

+ (void)cancelAllRequest
{
    //锁操作（互斥锁）
    @synchronized(self) {
        [[self allSessionTask]enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)URL
{
    if (!URL) {
        return;
    }
    //锁操作（互斥锁）
    @synchronized(self) {
        [[self allSessionTask]enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}

#pragma mark -- GET请求无缓存
+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(id)parameters
                  success:(LEEHttpRequestSuccess)success
                  failure:(LEEHttpRequestFailed)failure
{
    return [self GET:URL parameters:parameters responseCache:nil success:success failure:failure];
}

#pragma mark -- GET请求自动缓存
+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(id)parameters
            responseCache:(LEEHttpRequestCache)responseCache
                  success:(LEEHttpRequestSuccess)success
                  failure:(LEEHttpRequestFailed)failure
{
    //读取缓存
    responseCache != nil ? responseCache([LEENetworkCache httpCacheForURL:URL parameters:parameters]) : nil;
    
    NSURLSessionTask *sessionTask = [_sessionManager GET:URL parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {
            LEELog(@"responseObject:%@",responseObject);
        }
        [[self allSessionTask] removeObject:task];
        
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        responseCache != nil ? [LEENetworkCache setHttpCache:responseObject URL:URL parameters:parameters] : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            LEELog(@"error:%@",error);
        }
        [[self allSessionTask]removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    //添加sessionTask到数组
    sessionTask ? [[self allSessionTask]addObject:sessionTask] : nil;
    
    return sessionTask;
}

#pragma mark -- POST请求无缓存
+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(id)parameters
                   success:(LEEHttpRequestSuccess)success
                   failure:(LEEHttpRequestFailed)failure;
{
    return [self POST:URL parameters:parameters responseCache:nil success:success failure:failure];
}


#pragma mark -- POST请求，自动缓存
+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(id)parameters
             responseCache:(LEEHttpRequestCache)responseCache
                   success:(LEEHttpRequestSuccess)success
                   failure:(LEEHttpRequestFailed)failure;
{
    //读取缓存
    responseCache != nil ? responseCache([LEENetworkCache httpCacheForURL:URL parameters:parameters]) : nil;

#pragma mark /** 当后台服务端需要接收字符串类型请求参数，处理请求体参数 （每次网络请求都会走此方法，默认对parameters是不进行处理的,需要重写） */
//    [_sessionManager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
//        return parameters;
//    }];
    
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {
            LEELog(@"responseObject:%@",responseObject);
        }
        [[self allSessionTask] removeObject:task];
        
        success ? success(responseObject) : nil;
        //对数据进行异步缓存
        responseCache != nil ? [LEENetworkCache setHttpCache:responseObject URL:URL parameters:parameters] : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            LEELog(@"error:%@",error);
        }
        [[self allSessionTask]removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    //添加sessionTask到数组
    sessionTask ? [[self allSessionTask]addObject:sessionTask] : nil;
    
    return sessionTask;
}

#pragma mark -- 上传文件
+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(id)parameters
                                            name:(NSString *)name
                                        filePath:(NSString *)filePath
                                        progress:(LEEHttpProgress)progress
                                         success:(LEEHttpRequestSuccess)success
                                         failure:(LEEHttpRequestFailed)failure
{
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:name error:&error];
        (failure && error) ? failure(error) : nil;
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {
            LEELog(@"responseObject:%@",responseObject);
        }
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            LEELog(@"error,%@",error);
        }
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    //添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
    
    return sessionTask;
}

#pragma mark -- 上传单/多张图片
+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                             parameters:(id)parameters
                                   name:(NSString *)name
                                 images:(NSArray<UIImage *> *)images
                              fileNames:(NSArray<NSString *> *)fileNames
                             imageScale:(CGFloat)imageScale
                              imageType:(NSString *)imageType
                               progress:(LEEHttpProgress)progress
                                success:(LEEHttpRequestSuccess)success
                                failure:(LEEHttpRequestFailed)failure
{
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSUInteger i = 0; i<images.count; i++) {
            //图片经过等比压缩之后得到的二进制文件
            NSData *imageData = UIImageJPEGRepresentation(images[i], imageScale ?: 1.f);
            //默认图片的文件名，如果fileNames为nil就使用
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = NSStringFormat(@"%@%ld.%@",str,i,imageType?:@"jpg");
            
            [formData appendPartWithFileData:imageData
                                        name:name
                                    fileName:fileNames ? NSStringFormat(@"%@.%@",fileNames[i],imageType?:@"jpg"):imageFileName
                                    mimeType:NSStringFormat(@"image/%@",imageType?:@"jpg")];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) :nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_isOpenLog) {
            LEELog(@"responseObject:%@",responseObject);
        }
        [[self allSessionTask]removeObject:task];
        success ? success(responseObject) :nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_isOpenLog) {
            LEELog(@"error:%@",error);
        }
        
    }];
    
    return sessionTask;
}

#pragma mark -- 文件下载
+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL
                              fileDir:(NSString *)fileDir
                             progress:(LEEHttpProgress)progress
                              success:(void(^)(NSString *))success
                              failure:(LEEHttpRequestFailed)failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allSessionTask] removeObject:downloadTask];
        if (error && failure) {
            failure(error);
            return ;
        }
        //.absoluteString  NSURL->NSString
        success ? success(filePath.absoluteString) : nil;
    }];
    
    //开始下载
    [downloadTask resume];
    //添加sessionTask到数组
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil;
    
    return downloadTask;
}


/// 存储所有的task数组
+ (NSMutableArray *)allSessionTask
{
    if (!_allSessionTask) {
        _allSessionTask = [NSMutableArray array];
    }
    return _allSessionTask;
}

#pragma mark -- 初始化AFHTTPSessionManager相关属性
/**
 * 开始检测网络状态
 */
+ (void)load
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)initialize
{
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    //打开状态栏等待菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

#pragma mark -- 重置AFHTTPSessionManager相关属性

+ (void)setAFHTTPSessionManagerProperty:(void (^)(AFHTTPSessionManager *))sessionManager
{
    sessionManager ? sessionManager(_sessionManager) : nil;
}

+ (void)setRequestSerializer:(LEERequestSerializer)requestSerializer
{
    _sessionManager.requestSerializer = requestSerializer == LEERequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

+ (void)setResponseSerializer:(LEEResponseSerializer)responseSerializer
{
    _sessionManager.responseSerializer = responseSerializer == LEEResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}

+ (void)setRequestTimeOutInterval:(NSTimeInterval)time
{
    _sessionManager.requestSerializer.timeoutInterval = time;
}

+ (void)setQueryStringSerializationWithParameters:(id)parameters
{
#pragma mark /** 当后台服务端需要接收字符串类型请求参数，处理请求体参数 （每次网络请求都会走此方法，默认对parameters是不进行处理的,需要重写） */
    [_sessionManager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
        return parameters;
    }];
}

+ (void)setValue:(NSString *)value forHttpHeaderField:(NSString *)field
{
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}

+ (void)openNetworkActivityIndicator:(BOOL)open
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName
{
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    //使用证书模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:(AFSSLPinningModeCertificate)];
    // 如果需要验证自建证书（无效证书），需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = validatesDomainName;
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    
    [_sessionManager setSecurityPolicy:securityPolicy];
}

@end


#pragma mark - NSDictionary,NSArray的分类
/*
 ************************************************************************************
 *新建NSDictionary与NSArray的分类, 控制台打印json数据中的中文
 ************************************************************************************
 */

#ifdef DEBUG
@implementation NSArray (LEE)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    [strM appendString:@")"];
    
    return strM;
}

@end

@implementation NSDictionary (LEE)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [strM appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    
    [strM appendString:@"}\n"];
    
    return strM;
}
@end
#endif
