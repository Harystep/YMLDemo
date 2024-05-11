

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZCSaveUserData : NSObject

+ (void)saveUserToken:(NSString *)token;
+ (NSString *)getUserToken;

+ (void)saveUserCid:(NSString *)cid;
+ (NSString *)getUserCid;


@end

NS_ASSUME_NONNULL_END
