//
//  AppDelegate.m
//  GTDemo
//
//  Created by appleplay on 2023/11/23.
//

#import "AppDelegate.h"
#import <GTSDK/GeTuiSdk.h>
#import <AVFoundation/AVFoundation.h>
// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "DCUniMP.h"
#import "YDHomeController.h"
#import "ZCSaveUserData.h"

#define kGeTuiAppId @"w7NgvidZkg6vZfNZHxc3p1"
#define kGeTuiAppKey @"yyRIqegTHG8vLXMYEvU2U3"
#define kGeTuiAppSecret @"LtHIUB1BILA1x4tArGczY7"

@interface AppDelegate ()<GeTuiSdkDelegate, AVSpeechSynthesizerDelegate>

@property (nonatomic,strong) dispatch_queue_t queue1;
@property (nonatomic,strong) dispatch_semaphore_t semaphore;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.semaphore = dispatch_semaphore_create(0);
    self.queue1 = dispatch_queue_create("net.merchant.ylmQueue1", DISPATCH_QUEUE_SERIAL);
            
    [DCUniMPSDKEngine initSDKEnvironmentWithLaunchOptions:launchOptions];
    
    [self initializationWindow];
      
    [GeTuiSdk startSdkWithAppId:kGeTuiAppId appKey:kGeTuiAppKey appSecret:kGeTuiAppSecret delegate:self launchingOptions:launchOptions];
    //    // [ GTSDK ]：是否允许APP后台运行
    [GeTuiSdk runBackgroundEnable:YES];
    
    // 注册远程通知
    [GeTuiSdk registerRemoteNotification: (UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)];
    
    return YES;
}

- (void)initializationWindow {
    // 添加跟视图控制器
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    YDHomeController *vc = [[YDHomeController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // 清除角标
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
}

/// 通知展示（iOS10及以上版本）
/// @param center center
/// @param notification notification
/// @param completionHandler completionHandler
- (void)GeTuiSdkNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification completionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSString *msg = [NSString stringWithFormat:@"[ TestDemo ] [APNs] %@ \n%@", NSStringFromSelector(_cmd), notification.request.content.userInfo];
    
    // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要，判断是否要提示用户Badge、Sound、Alert等
    //completionHandler(UNNotificationPresentationOptionNone); 若不显示通知，则无法点击通知
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

/// 收到通知信息
/// @param userInfo apns通知内容
/// @param center UNUserNotificationCenter（iOS10及以上版本）
/// @param response UNNotificationResponse（iOS10及以上版本）
/// @param completionHandler 用来在后台状态下进行操作（iOS10以下版本）
- (void)GeTuiSdkDidReceiveNotification:(NSDictionary *)userInfo notificationCenter:(UNUserNotificationCenter *)center response:(UNNotificationResponse *)response fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSString *msg = [NSString stringWithFormat:@"[ TestDemo ] [APNs] %@ \n%@", NSStringFromSelector(_cmd), userInfo];
    if(completionHandler) {
        // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要自行修改参数值
        
        completionHandler(UIBackgroundFetchResultNoData);
    }
}


/// 收到透传消息
/// @param userInfo    推送消息内容
/// @param fromGetui   YES: 个推通道  NO：苹果apns通道
/// @param offLine     是否是离线消息，YES.是离线消息
/// @param appId       应用的appId
/// @param taskId      推送消息的任务id
/// @param msgId       推送消息的messageid
/// @param completionHandler 用来在后台状态下进行操作（通过苹果apns通道的消息 才有此参数值）
- (void)GeTuiSdkDidReceiveSlience:(NSDictionary *)userInfo fromGetui:(BOOL)fromGetui offLine:(BOOL)offLine appId:(NSString *)appId taskId:(NSString *)taskId msgId:(NSString *)msgId fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // [ GTSDK ]：汇报个推自定义事件(反馈透传消息)，开发者可以根据项目需要决定是否使用, 非必须
    // [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
    NSString *contentStr;
    NSDictionary *dataDic = [self dictionaryDataWithString:userInfo[@"payload"]];
    NSLog(@"getui---->%@", dataDic);
    NSDictionary *transData = [self dictionaryDataWithString:dataDic[@"transData"]];
    NSString *type = transData[@"type"];
    if ([type isEqualToString:@"amount"]) {
        contentStr = [NSString stringWithFormat:@"易来米到账%@元", transData[@"amount"]];
    } else {
        contentStr = @"收款失败用户已取消";
    }
    if (fromGetui&&(!offLine)) {
        [self playAudioTitle:contentStr];
    }
    
    if(completionHandler) {
        // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要自行修改参数值
        completionHandler(UIBackgroundFetchResultNoData);
    }
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

- (void)GeTuiSdkNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification {
    // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要自行修改参数值
}


- (void)GeTuiSdkDidOccurError:(NSError *)error {
    NSString *msg = [NSString stringWithFormat:@"[ TestDemo ] [GeTuiSdk GeTuiSdkDidOccurError]:%@\n\n",error.localizedDescription];

    // SDK发生错误时，回调异常错误信息
    NSLog(@"%@", msg);
}

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    //个推SDK已注册，返回clientId
    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
    [ZCSaveUserData saveUserCid:clientId];
}

- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)status {
    NSLog(@"[GetuiSdk Status]:%u", status);
}

// 语音播报
- (void)playAudioTitle:(NSString*)aText {
    dispatch_async(self.queue1, ^{
        [self playSpeechLocalContent:aText];
    });
}

- (void)playSpeechLocalContent:(NSString *)content {
    // 后台语音播报需要设置
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    AVSpeechSynthesizer *speech = [[AVSpeechSynthesizer alloc] init];
    speech.delegate = self;
    [speech stopSpeakingAtBoundary:AVSpeechBoundaryWord];

    NSError *errr1;
    NSError *errr2;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&errr1];
    [[AVAudioSession sharedInstance] setActive:YES error:&errr2];

    //设置发音，这是中文普通话
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    //需要转换的文字
    AVSpeechUtterance *utterance  = [[AVSpeechUtterance alloc] initWithString:content];
    // 设置语速，范围0-1，注意0最慢，1最快；
    utterance.rate  = 0.55;
    utterance.voice = voice;
    //开始
    [speech speakUtterance:utterance];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}


@end
