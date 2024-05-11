//
//  SYBMusicData.h
//  CashierChoke
//
//  Created by warmStep on 2021/5/19.
//  Copyright © 2021 zjs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYBMusicData : NSObject

+ (NSMutableArray *)caluateMoney:(NSString *)content;

+ (NSMutableArray *)caluateDictMoney:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
