

#import "ZCUserInfoService.h"
#import "ZCNetwork.h"
#import "ZCSaveUserData.h"

#define kEnterMachineRoomURL @"merchant/aliasId/save"

@implementation ZCUserInfoService

+ (void)bindUserCidOperate:(NSDictionary *)params completeHandler:(void (^)(id responseObj))completerHandler {
    NSString *url = [NSString stringWithFormat:@"%@?aliasId=%@&deviceType=ios", kEnterMachineRoomURL, [ZCSaveUserData getUserCid]];
    [[ZCNetwork shareInstance] request_getWithApi:url params:params isNeedSVP:YES success:^(id  _Nullable responseObj) {
        completerHandler(responseObj);
    } failed:^(id  _Nullable data) {
        
    }];
}

@end
