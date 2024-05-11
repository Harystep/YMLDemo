

#import <Foundation/Foundation.h>


typedef void(^CompleteHandler)(id _Nullable responseObj);
typedef void(^FaildureHandler)(id _Nullable data);


NS_ASSUME_NONNULL_BEGIN

@interface ZCNetwork : NSObject

+ (instancetype)shareInstance;

- (void)request_getWithApi:(NSString *)api
                    params:(nullable id)params
                    isNeedSVP:(BOOL)isNeed
                   success:(CompleteHandler)success
                    failed:(FaildureHandler)failed;

- (void)request_postWithApi:(NSString *)api
                    params:(nullable id)params
                    isNeedSVP:(BOOL)isNeed
                   success:(CompleteHandler)success
                     failed:(FaildureHandler)failed;

@end

NS_ASSUME_NONNULL_END
