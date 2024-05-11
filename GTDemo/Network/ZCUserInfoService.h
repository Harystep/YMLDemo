

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCUserInfoService : NSObject

+ (void)bindUserCidOperate:(NSDictionary *)params completeHandler:(void (^)(id responseObj))completerHandler;

@end

NS_ASSUME_NONNULL_END
