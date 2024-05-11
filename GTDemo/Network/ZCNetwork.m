//
//  ZCNetwork.m
//  PowerDance
//
//  Created by PC-N121 on 2021/10/27.
//

#import "ZCNetwork.h"
#import <AFNetworking/AFNetworking.h>
#import "ZCSaveUserData.h"

#define MAINWINDOW  [UIApplication sharedApplication].keyWindow

@interface ZCNetwork ()

@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@property (nonatomic, copy) NSString *host;

@end

static ZCNetwork *instanceManager = nil;

@implementation ZCNetwork

/** 重写 allocWithZone: 方法 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instanceManager == nil) {
            instanceManager = [super allocWithZone:zone];
            [instanceManager loadHost];
        }
    });
    return instanceManager;
}
/** 重写 copyWithZone: 方法 */
- (id)copyWithZone:(NSZone *)zone {
    
    return instanceManager;
}
/** 单例模式创建  */
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instanceManager) {
            instanceManager = [[self alloc] init];
        }
    });
    return instanceManager;
}

/**
 *  @brief  data 转 字典
 */
- (NSDictionary *)dataReserveForDictionaryWithData:(id)data {
    
    if ([data isKindOfClass:[NSData class]]) {
        
        return [NSJSONSerialization JSONObjectWithData:data
                                               options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                 error:nil];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        
        return data;
    } else {
        
        return nil;
    }
}

/**
 *  @brief  字典转json字符串方法
 *  @param dict 字典
 *  @return 字符串
 */
- (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError * error;
    // 字典转 data
    NSData  * jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:&error];
    NSString *jsonString;
    if (!jsonData) {
        
    }
    else {
        jsonString = [[NSString alloc]initWithData:jsonData
                                          encoding:NSUTF8StringEncoding];
        // 替换掉 url 地址中的 \/
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    //去掉字符串中的空格
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" "
                            withString:@""
                               options:NSLiteralSearch range:range];
    
    //去掉字符串中的换行符
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n"
                            withString:@""
                               options:NSLiteralSearch range:range2];
    
    return mutStr;
}

#pragma mark : --
- (void)request_postWithApi:(NSString *)api
                    params:(nullable id)params
                    isNeedSVP:(BOOL)isNeed
                   success:(CompleteHandler)success
                    failed:(FaildureHandler)failed {
   
    //post 请求
    NSString *url = [[ZCNetwork shareInstance].host stringByAppendingString:api];
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/plain", @"application/msexcel", nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = responseSerializer;
    [manager POST:url parameters:params headers:[self headDic] progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self printRequestData:task reoponseObject:responseObject];
            [self handleResultWithModelClass:isNeed success:success failed:failed reponseObj:responseObject];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    
}

- (void)request_getWithApi:(NSString *)api
                    params:(nullable id)params
                    isNeedSVP:(BOOL)isNeed
                   success:(CompleteHandler)success
                    failed:(FaildureHandler)failed {
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer.timeoutInterval = 15.0;
    NSString *url;
    if (![api hasPrefix:@"http"]) {
        url = [[ZCNetwork shareInstance].host stringByAppendingString:api];
    } else {
        url = api;
    }
 
    
    [self.sessionManager GET:url
      parameters:params
         headers:[self headDic]
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self printRequestData:task reoponseObject:responseObject];
            [self handleResultWithModelClass:isNeed success:success failed:failed reponseObj:responseObject];
          
        }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failed(error);
                
    }];
}



- (void)printRequestData:(NSURLSessionDataTask *)task reoponseObject:(id)obj{
    NSLog(@"---------------------------------------------");
    NSLog(@"\n\n🐱请求URL:%@\n🐱请求方式:%@\n🐱请求头信息:%@\n🐱请求正文信息:%@\n",task.originalRequest.URL,task.originalRequest.HTTPMethod,task.originalRequest.allHTTPHeaderFields,[[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    if ([NSJSONSerialization isValidJSONObject:obj]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
        NSString *responseJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"\n✅success✅:\n%@\n\n", responseJson);
    }
    NSLog(@"---------------------------------------------");
}

- (void)handleResultWithModelClass:(BOOL)isNeed
                           success:(CompleteHandler)success
                            failed:(FaildureHandler)failed
                        reponseObj:(id)obj {
    // 成功，解析 respoObject
    NSDictionary *dict = [self dataReserveForDictionaryWithData:obj];
    if (dict) {
        // 判断后台返回的 code 是否为零
        if ([dict[@"errCode"] integerValue] == 0) {
            success(dict);
        } else {
            failed(dict);
        }
    }
}


- (void)loadHost {
#ifdef DEBUG   
    self.host = @"https://ecloud-api.51sssd.com/api/";//k_Api_Host_Debug; k_Api_Host_Relase
#else
    self.host = @"https://ecloud-api.51sssd.com/api/";
#endif
}

- (NSDictionary *)headDic {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[ZCSaveUserData getUserToken] forKey:@"access_token"];
    return [dic copy];
}

// Lazy Load sessionManager
- (AFHTTPSessionManager *)sessionManager {
    
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer.timeoutInterval = 20.f;
        [_sessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        [_sessionManager.requestSerializer didChangeValueForKey: @"timeoutInterval"];
        
        NSSet * set = [NSSet setWithObjects:@"text/html", @"text/plain", @"application/json", nil];
        _sessionManager.responseSerializer.acceptableContentTypes = [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObjectsFromSet:set];
        [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"content-type"];
        
        _sessionManager.requestSerializer  = [AFJSONRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _sessionManager;
}

@end
