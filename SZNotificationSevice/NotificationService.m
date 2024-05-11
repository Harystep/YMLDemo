//
//  NotificationService.m
//  SZNotificationSevice
//
//  Created by appleplay on 2023/11/23.
//

#import "NotificationService.h"
#import <AVFoundation/AVFoundation.h>
#import "KNAudioTool.h"
#import "KNApnsHelper.h"
#import "YJMacro.h"
#import "SYBMusicData.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    //iOS12.1系统以上语音播报无法使用语音播放器
    
    //ios15 需要设置interruptionLevel
    
    __weak __typeof__(self) weakSelf = self;
    
    NSDictionary *userInfo = request.content.userInfo;
    NSString *contentStr;
    NSDictionary *dataDic = [self dictionaryDataWithString:userInfo[@"payload"]];
    NSDictionary *transData = [self dictionaryDataWithString:dataDic[@"transData"]];
    NSString *type = transData[@"type"];
    NSMutableArray *sourceURLsArr = [NSMutableArray array];
    if ([type isEqualToString:@"amount"]) {
        contentStr = [NSString stringWithFormat:@"易来米到账%@元", transData[@"amount"]];
        sourceURLsArr = [SYBMusicData caluateMoney:contentStr];
    } else {
        [sourceURLsArr addObject:@"cancelPaymentVoice.mp3"];
    }
    if (@available(iOS 15.0, *)) {
        
        //            NSNumber *amountNum = [NSNumber numberWithDouble:161.11];
        //            double amount = [amountNum doubleValue];
        //            NSMutableArray *sourceURLsArr = [KNApnsHelper getsourceURLsArr:amount];
        // 合并音频文件生成新的音频
        [KNApnsHelper mergeAVAssetWithSourceURLs:sourceURLsArr completed:^(NSString *soundName, NSURL *soundsFileURL) {
            if (!soundName) {
                NSLog(@"声音生成失败!");
                //                completed();
                weakSelf.contentHandler(weakSelf.bestAttemptContent);
                return;
            }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 150000
            if (@available(iOS 15.0, *)) {
                weakSelf.bestAttemptContent.interruptionLevel = UNNotificationInterruptionLevelTimeSensitive;
            }
#endif
            UNNotificationSound * sound = [UNNotificationSound soundNamed:soundName];
            weakSelf.bestAttemptContent.sound = sound;
            //            NSMutableDictionary *dict = [weakSelf.bestAttemptContent.userInfo mutableCopy] ;
            //            [dict setObject:[NSNumber numberWithBool:YES] forKey:@"hasHandled"] ;
            //            weakSelf.bestAttemptContent.userInfo = dict;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.contentHandler(self.bestAttemptContent);
                NSLog(@"完成 %@: dict->%@", NSStringFromClass([self class]), self.bestAttemptContent.userInfo);
            });
        }];
        
        return;
    }
    NSDictionary *temDic = @{@"payload":contentHandler,
                             @"type":type
    };
    [[KNAudioTool sharedPlayer] playPushInfo:temDic backModes:YES completed:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableDictionary *dict = [strongSelf.bestAttemptContent.userInfo mutableCopy] ;
            [dict setObject:[NSNumber numberWithBool:YES] forKey:@"hasHandled"] ;
            strongSelf.bestAttemptContent.userInfo = dict;
            
            strongSelf.contentHandler(self.bestAttemptContent);
        }
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

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
