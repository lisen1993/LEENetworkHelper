//
//  LEENetworkHelper.h
//  LEENetworkHelper
//
//  Created by 西瓜Team on 2018/9/5.
//  Copyright © 2018年 LEESen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LEENetworkCache.h"

#ifndef kIsNetwork
#define kIsNetwork
#endif

typedef NS_ENUM(NSUInteger, LEENetworkStatusType) {
    //未知网络
    LEENetworkStatusUnknow,
    //无网络
    LEENetworkStatusNotReachable,
    //手机网络
    LEENetworkStatusReachableViaWWAN,
    //WIFI网络
    LEENetworkStatusReachableViaWIFI
};

typedef NS_ENUM(NSUInteger, LEERequestSerializer) {
    //设置请求参数为JSON格式
    LEERequestSerializerJSON,
    //设置请求参数为二进制格式
    LEERequestSerializerHTTP
};

typedef NS_ENUM(NSUInteger, LEEResponseSerializer) {
    //设置响应数据格式为JSON格式
    LEEResponseSerializerJSON,
    //设置响应数据格式为二进制格式
    LEEResponseSerializerHTTP
};

//请求数据成功回调block
typedef void(^LEEHttpRequestSuccess)(id responseObject);

//请求失败的回调block
typedef void(^LEEHttpRequestFailed)(NSError *error);

//缓存的block
typedef void(^LEEHttpRequestCache)(id responseCache);

//上传或下载进度 , Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小
typedef void(^LEEHttpProgress)(NSProgress *progress);

//网络状态block
typedef void(^LEENetworkStatus)(LEENetworkStatusType status);

@class AFHTTPSessionManager;

@interface LEENetworkHelper : NSObject

/// 是否有网 YES有，NO无
+ (BOOL)isNetwork;

/// 手机网络：YES，反之NO
+ (BOOL)isWWANNetwork;

/// WIFI网络：YES，反之NO
+ (BOOL)isWIFINetwork;

/// 取消所有http请求
+ (void)cancelAllRequest;

/// 实时获取网络状态，通过block回调实时获取（此方法可多次调用）
+ (void)networkStatusWithBlock:(LEENetworkStatus)networkStatus;

/// 取消指定URL的http请求
+ (void)cancelRequestWithURL:(NSString *)URL;

/// 开启打印日志（DEBUG级别）
+ (void)openLog;

/// 关闭打印日志，默认关闭
+ (void)closeLog;

/**
 * GET请求无缓存
 *
 * @param URL        请求地址
 * @param parameters 请求参数
 * @param success    请求成功回调
 * @param failure    请求失败回调
 *
 * @return 返回的对象可取消请求，调用cancel方法
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(id)parameters
                           success:(LEEHttpRequestSuccess)success
                           failure:(LEEHttpRequestFailed)failure;

/**
 * GET请求，自动缓存
 *
 * @param URL           请求地址
 * @param parameters    请求参数
 * @param responseCache 缓存数据回调
 * @param success       请求成功回调
 * @param failure       请求失败回调
 *
 * @return 返回的对象可取消请求，调用cancel方法
 */
+ (__kindof NSURLSessionTask *)GET:(NSString *)URL
                        parameters:(id)parameters
                     responseCache:(LEEHttpRequestCache)responseCache
                           success:(LEEHttpRequestSuccess)success
                           failure:(LEEHttpRequestFailed)failure;

/**
 * POST请求，无缓存
 *
 * @param URL        请求地址
 * @param parameters 请求参数
 * @param success    请求成功回调
 * @param failure    请求失败回调
 *
 * @return 返回的对象可取消请求，调用cancel方法
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                        parameters:(id)parameters
                           success:(LEEHttpRequestSuccess)success
                           failure:(LEEHttpRequestFailed)failure;

/**
 * POST请求，自动缓存
 *
 * @param URL           请求地址
 * @param parameters    请求参数
 * @param responseCache 缓存数据回调
 * @param success       请求成功回调
 * @param failure       请求失败回调
 *
 * @return 返回的对象可取消请求，调用cancel方法
 */
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                        parameters:(id)parameters
                     responseCache:(LEEHttpRequestCache)responseCache
                           success:(LEEHttpRequestSuccess)success
                           failure:(LEEHttpRequestFailed)failure;

/**
 * 上传文件
 *
 * @param URL           请求地址
 * @param parameters    请求参数
 * @param name          文件对应服务器上的字段
 * @param filePath      文件本地的沙盒路径
 * @param success       请求成功回调
 * @param failure       请求失败回调
 *
 * @return 返回的对象可取消请求，调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(id)parameters
                                            name:(NSString *)name
                                        filePath:(NSString *)filePath
                                        progress:(LEEHttpProgress)progress
                                         success:(LEEHttpRequestSuccess)success
                                         failure:(LEEHttpRequestFailed)failure;

/**
 * 上传单/多张图片
 *
 * @param URL           请求地址
 * @param parameters    请求参数
 * @param name          图片对应服务器上的字段
 * @param images        图片数组
 * @param fileNames     图片名称数组，可以为nil，数组内文件名默认为当前日期时间“yyyyMMddHHmmss”
 * @param imageScale    图片文件压缩比 范围（0.f~1.f）
 * @param imageType     图片类型 例如：png，jpg（默认类型）。。。
 * @param progress      上传进度信息
 * @param success       请求成功回调
 * @param failure       请求失败回调
 *
 * @return 返回的对象可取消请求，调用cancel方法
 */
+ (__kindof NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                                      parameters:(id)parameters
                                            name:(NSString *)name
                                          images:(NSArray<UIImage *> *)images
                                       fileNames:(NSArray<NSString *> *)fileNames
                                      imageScale:(CGFloat)imageScale
                                       imageType:(NSString *)imageType
                                        progress:(LEEHttpProgress)progress
                                         success:(LEEHttpRequestSuccess)success
                                         failure:(LEEHttpRequestFailed)failure;


/**
 * 下载文件
 *
 * @param URL      请求地址
 * @param fileDir  文件存储目录(默认存储目录为Download)
 * @param progress 文件下载进度信息
 * @param success  下载成功回调（回调参数filePath：文件的路径）
 * @param failure  下载失败回调
 *
 * @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)URL
                                       fileDir:(NSString *)fileDir
                                      progress:(LEEHttpProgress)progress
                                       success:(void(^)(NSString *))success
                                       failure:(LEEHttpRequestFailed)failure;


#pragma mark -- 设置AFHTTPSessionManager相关属性
#pragma mark -- 注意：因为全局只有一个AFHTTPSessionManager实例，所以一下设置方式全局生效

/**
 * 在开发中如果一下配置不满足项目的需求，就调用此方法获取AFHTTPSessionManager实例进行自定义设置
   （注意：调用此方法是需要导入AFNetworking.h头文件，否则可能会报找不到AFHTTPSessionManager的❌）
 *
 * @param sessionManager  AFHTTPSessionManager的实例
 */
+ (void)setAFHTTPSessionManagerProperty:(void(^)(AFHTTPSessionManager *sessionManager))sessionManager;

/**
 * 设置网络请求参数的格式：默认为二进制格式
 *
 * @param requesSerializer  LEERequestSerializerJSON为JSON格式，LEERequestSerializerHTTP为二进制格式
 */
+ (void)setRequestSerializer:(LEERequestSerializer)requestSerializer;

/**
 * 设置服务器响应数据格式：默认为JSON格式
 *
 * @param responseSerializer  LEEResponseSerializerJSON为JSON格式，LEEResponseSerializerHTTP为二进制格式
 */
+ (void)setResponseSerializer:(LEEResponseSerializer)responseSerializer;

/**
 * 设置请求超时时长：默认为30s
 *
 * @param time 时长
 */
+ (void)setRequestTimeOutInterval:(NSTimeInterval)time;

///  当后台服务端需要接收字符串类型请求参数，处理请求体参数 （每次网络请求都会走此方法，默认对parameters是不进行处理的,需要重写）
+ (void)setQueryStringSerializationWithParameters:(id)parameters;

/// 设置请求头
+ (void)setValue:(NSString *)value forHttpHeaderField:(NSString *)field;

/**
 * 是否打开网络状态下转菊花：默认打开
 *
 * @param open YES(打开),NO(关闭)
 */
+ (void)openNetworkActivityIndicator:(BOOL)open;


/**
 配置自建证书的Https请求, 参考链接: http://blog.csdn.net/syg90178aw/article/details/52839103
 
 @param cerPath 自建Https证书的路径
 @param validatesDomainName 是否需要验证域名，默认为YES. 如果证书的域名与请求的域名不一致，需设置为NO; 即服务器使用其他可信任机构颁发
 的证书，也可以建立连接，这个非常危险, 建议打开.validatesDomainName=NO, 主要用于这种情况:客户端请求的是子域名, 而证书上的是另外
 一个域名。因为SSL证书上的域名是独立的,假如证书上注册的域名是www.google.com, 那么mail.google.com是无法验证通过的.
 */
+ (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;







@end
