//
//  ViewController.m
//  GTDemo
//
//  Created by appleplay on 2023/11/23.
//

#import "YDHomeController.h"
#import "DCUniMP.h"
#import "ZCSaveUserData.h"
#import "ZCUserInfoService.h"

@interface YDHomeController ()<DCUniMPSDKEngineDelegate>

@property (nonatomic, weak) DCUniMPInstance *uniMPInstance;

@property (nonatomic, copy) NSString *uniappID;

@end

@implementation YDHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *bgIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_bg_icon"]];
    [self.view addSubview:bgIcon];
    bgIcon.frame = self.view.bounds;
    bgIcon.contentMode = UIViewContentModeScaleAspectFill;
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.uniappID = @"__UNI__54F11ED";
    [self setUniMPMenuItems];
    [self checkUniMPResource];
}


/// 检查运行目录是否存在应用资源，不存在将应用资源部署到运行目录
- (void)checkUniMPResource {
    NSString *appResourcePath = [[NSBundle mainBundle] pathForResource:self.uniappID ofType:@"wgt"];;
    if (!appResourcePath) {
        NSLog(@"资源路径不正确，请检查");
        return;
    }
    // 将应用资源部署到运行路径中
    NSError *error;
    if ([DCUniMPSDKEngine installUniMPResourceWithAppid:self.uniappID resourceFilePath:appResourcePath password:nil error:&error]) {
        NSLog(@"小程序 %@ 应用资源文件部署成功，版本信息：%@", self.uniappID, [DCUniMPSDKEngine getUniMPVersionInfoWithAppid:self.uniappID]);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        });
        [self preloadUniMP];
    } else {
        NSLog(@"小程序 %@ 应用资源部署失败： %@", self.uniappID, error);
    }

}

/// 配置胶囊按钮菜单 ActionSheet 全局项（点击胶囊按钮 ··· ActionSheet弹窗中的项）
- (void)setUniMPMenuItems {
    
    DCUniMPMenuActionSheetItem *item1 = [[DCUniMPMenuActionSheetItem alloc] initWithTitle:@"将小程序隐藏到后台" identifier:@"enterBackground"];
    DCUniMPMenuActionSheetItem *item2 = [[DCUniMPMenuActionSheetItem alloc] initWithTitle:@"关闭小程序" identifier:@"closeUniMP"];
    
//     运行内置的 __UNI__CBDCE04 小程序，点击进去 小程序-原生通讯 页面，打开下面的注释，并将 item3 添加到 MenuItems 中，可以测试原生向小程序发送事件
//    DCUniMPMenuActionSheetItem *item3 = [[DCUniMPMenuActionSheetItem alloc] initWithTitle:@"SendUniMPEvent" identifier:@"SendUniMPEvent"];
    // 添加到全局配置
    [DCUniMPSDKEngine setDefaultMenuItems:@[item1,item2]];
    [DCUniMPSDKEngine setCapsuleButtonHidden:YES];
    // 设置 delegate
    [DCUniMPSDKEngine setDelegate:self];
}
/// 预加载后打开小程序
- (void)preloadUniMP {
    
    // 获取配置信息
    DCUniMPConfiguration *configuration = [[DCUniMPConfiguration alloc] init];
    
    NSLog(@"%@", configuration.extraData);
    // 开启后台运行
    configuration.enableBackground = YES;
    
    // 设置打开方式
    configuration.openMode = DCUniMPOpenModePresent;
    
    // 启用侧滑手势关闭小程序
    configuration.enableGestureClose = NO;
    
    
    __weak __typeof(self)weakSelf = self;
    // 预加载小程序
    [DCUniMPSDKEngine preloadUniMP:self.uniappID configuration:configuration completed:^(DCUniMPInstance * _Nullable uniMPInstance, NSError * _Nullable error) {
        if (uniMPInstance) {
            weakSelf.uniMPInstance = uniMPInstance;
            // 预加载后打开小程序
            [uniMPInstance showWithCompletion:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"show 小程序失败：%@",error);
                }
            }];
        } else {
            NSLog(@"预加载小程序出错：%@",error);
        }
    }];
}

#pragma mark - DCUniMPSDKEngineDelegate
/// 胶囊按钮‘x’关闭按钮点击回调
- (void)closeButtonClicked:(NSString *)appid {
    NSLog(@"点击了 小程序 %@ 的关闭按钮",appid);
    [self.uniMPInstance closeWithCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"关闭成功");
        }
    }];
       
}

/// DCUniMPMenuActionSheetItem 点击触发回调方法
- (void)defaultMenuItemClicked:(NSString *)appid identifier:(NSString *)identifier {
    NSLog(@"标识为 %@ 的 item 被点击了", identifier);
    
    // 将小程序隐藏到后台
    if ([identifier isEqualToString:@"enterBackground"]) {
        __weak __typeof(self)weakSelf = self;
        [self.uniMPInstance hideWithCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"小程序 %@ 进入后台",weakSelf.uniMPInstance.appid);
            } else {
                NSLog(@"hide 小程序出错：%@",error);
            }
        }];
    }
    // 关闭小程序
    else if ([identifier isEqualToString:@"closeUniMP"]) {
        [self.uniMPInstance closeWithCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"小程序 closed");
            } else {
                NSLog(@"close 小程序出错：%@",error);
            }
        }];
    }
    // 向小程序发送消息
    else if ([identifier isEqualToString:@"SendUniMPEvent"]) {
        [self.uniMPInstance sendUniMPEvent:@"NativeEvent" data:@{@"msg":@"native message"}];
    }
}

/// 小程序向原生发送事件回调方法
/// @param appid 对应小程序的appid
/// @param event 事件名称
/// @param data 数据：NSString 或 NSDictionary 类型
/// @param callback 回调数据给小程序
- (void)onUniMPEventReceive:(NSString *)appid event:(NSString *)event data:(id)data callback:(DCUniMPKeepAliveCallback)callback {
    NSLog(@"Receive UniMP:%@ event:%@ data:%@", appid, event, data);
    // 回传数据给小程序
    // DCUniMPKeepAliveCallback 用法请查看定义说明
    NSDictionary *dataDic = data;
    if (callback) {
        if ([event isEqualToString:@"needToken"]) {
            [ZCSaveUserData saveUserToken:dataDic[@"token"]];
            [self bindUserCidOp];
        }
        callback(@"native callback message",NO);
    }
}

- (void)bindUserCidOp {
    [ZCUserInfoService bindUserCidOperate:@{} completeHandler:^(id  _Nonnull responseObj) {
        NSLog(@"%@", responseObj);
    }];
}

- (NSDictionary *)dictionaryDataWithString:(id)content {
    if (content == nil) {
        return nil;
    }
    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)hideUniAppOperate {
    [self.uniMPInstance hideWithCompletion:^(BOOL success, NSError * _Nullable error) {
    }];
}

- (void)showUniAppOperate {
    [self.uniMPInstance showWithCompletion:^(BOOL success, NSError * _Nullable error) {
    }];
}

/// 小程序关闭回调方法
- (void)uniMPOnClose:(NSString *)appid {
    NSLog(@"小程序 %@ 被关闭了",appid);
    
    self.uniMPInstance = nil;
        
    // 可以在这个时机再次打开小程序
//    [self openUniMP:nil];
}

@end
