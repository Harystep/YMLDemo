
#import "ZCSaveUserData.h"

@implementation ZCSaveUserData

+ (void)saveUserToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"kSaveUserTokenKey"];
}

+ (NSString *)getUserToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"kSaveUserTokenKey"];
}

+ (void)saveUserCid:(NSString *)cid {
    [[NSUserDefaults standardUserDefaults] setValue:cid forKey:@"kSaveUserCidKey"];
}

+ (NSString *)getUserCid {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"kSaveUserCidKey"];
}

@end
