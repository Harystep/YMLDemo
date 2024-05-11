//
//  SYBMusicData.m
//  CashierChoke
//
//  Created by warmStep on 2021/5/19.
//  Copyright © 2021 zjs. All rights reserved.
//

#import "SYBMusicData.h"

@implementation SYBMusicData

+ (NSMutableArray *)caluateDictMoney:(NSString *)content {

    NSString * integer = @"";
    NSString * demical = @"";
    NSMutableArray * array = [NSMutableArray array];
    NSDictionary *moneyDic = [self getNumberDictFromContent:content];
    NSString *money = moneyDic[@"account"];
    NSString *accountStr = [content componentsSeparatedByString:@"，"].firstObject;
    NSArray * moneyArray = [money componentsSeparatedByString:@"."];
    NSArray * integerArray = @[@"tts_0",@"tts_1",@"tts_2",@"tts_3",@"tts_4",@"tts_5",@"tts_6",@"tts_7",@"tts_8",@"tts_9"];
    NSArray * radices = @[@"", @"tts_ten", @"tts_hundred", @"tts_thousand"];

    NSArray * bigRadices = @[@"", @"tts_ten_thousand", @"tts_ten_million"];

    if (moneyArray.count == 1) {
        integer = [moneyArray firstObject];
    }else{
        integer = moneyArray.firstObject;
        demical = moneyArray.lastObject;
    }

    if ([content containsString:@"易来米到账"]) {

        [array addObject:@"tts_pre"];

    }else if ([content containsString:@"会员充值"]) {
        [array addObject:@"huiyuanchongzhi"];

    }else if ([content containsString:@"会员消费"]){

        [array addObject:@"huiyuanxiaofei"];
    }

    if ([integer intValue] == 0) {
        [array addObject:@"tts_0"];
    }

    if ([integer intValue] >0) {

        NSInteger zeroCount = 0;

        NSInteger integerNumber = integer.length % 4;

        for (int i = 0; i < integer.length; i++) {

            NSInteger p       = integer.length -1 - i;
            NSInteger modulus = p % 4;
            NSInteger quotient = (int)(p / 4);
            NSString *temp = [integer substringWithRange:NSMakeRange(i,1)];

            if ([temp isEqualToString:@"0"] ) {
                zeroCount ++;

            }else{
                if (zeroCount > 0) {
                    [array addObject: [integerArray firstObject]];
                }
                zeroCount = 0 ;

                /// 判断是否是十到二十之间 第一个数

                    if (integerNumber == 2 && i == 0) {

                         NSString *number = [integer substringWithRange:NSMakeRange(0,2)];



                        if ([number intValue] <10 || [number intValue] >= 20) {
                            [array addObject:integerArray[[temp intValue]]];
                        }

                    }else{
                        [array addObject:integerArray[[temp intValue]]];
                    }


                if (![radices[modulus] isEqualToString:@""]) {
                    [array addObject:radices[modulus]];
                }


            }

            if ( modulus == 0 && zeroCount < 4 ) {

                if (![bigRadices[quotient] isEqualToString:@""]) {
                    [array addObject:bigRadices[quotient]];
                }

                zeroCount = 0;
            }
        }
    }
    if ([accountStr containsString:@"."]) {
        [array addObject:@"tts_dot"];
    }
    if ([demical intValue] >=0) {

        for (int i = 0;  i <demical.length; i ++) {

            NSString *temp = [demical substringWithRange:NSMakeRange(i,1)];
            NSString * str = [NSString stringWithFormat:@"tts_%@",[temp copy]];

            [array addObject:str];
        }

        if (demical.length == 2) {
            NSString * first = [demical substringWithRange:NSMakeRange(0, 1)];
            NSString * last = [demical substringWithRange:NSMakeRange(1, 1)];

            if ([first isEqualToString:last]) {

                [array removeLastObject];
                [array addObject:[NSString stringWithFormat:@"tts_%@_copy",first]];

            }
        }
    }

    if ([money floatValue] == 0) {
        return nil;
    }
    [array addObject:[NSString stringWithFormat:@"%@",@"tts_yuan"]];
    
    NSString *coupon = moneyDic[@"coupon"];
    NSArray *couponArr = [coupon componentsSeparatedByString:@"."];
    NSString *couponStr = [content componentsSeparatedByString:@"，"].lastObject;
    [self caluateCouponMoney:couponArr integerArray:integerArray radices:radices bigRadices:bigRadices accept:array content:couponStr];
    [array addObject:[NSString stringWithFormat:@"%@",@"tts_yuan"]];
    
    NSMutableArray *temArr = [NSMutableArray array];
    for (NSString *key in array) {
        [temArr addObject:[NSString stringWithFormat:@"%@.mp3", key]];
    }
    
    return temArr;
}


+ (void)caluateCouponMoney:(NSArray *)moneyArray integerArray:(NSArray *)integerArray radices:(NSArray *)radices bigRadices:(NSArray *)bigRadices accept:(NSMutableArray *)array content:(NSString *)content {
    NSString * integer = @"";
    NSString * demical = @"";
    if (moneyArray.count == 1) {
        integer = [moneyArray firstObject];
    }else{
        integer = moneyArray.firstObject;
        demical = moneyArray.lastObject;
    }

    [array addObject:@"youhui"];
    
    if ([integer intValue] == 0) {
        [array addObject:@"tts_0"];
    }

    if ([integer intValue] > 0) {

        NSInteger zeroCount = 0;

        NSInteger integerNumber = integer.length % 4;

        for (int i = 0; i < integer.length; i++) {

            NSInteger p       = integer.length -1 - i;
            NSInteger modulus = p % 4;
            NSInteger quotient = (int)(p / 4);
            NSString *temp = [integer substringWithRange:NSMakeRange(i,1)];

            if ([temp isEqualToString:@"0"] ) {
                zeroCount ++;

            }else{
                if (zeroCount > 0) {
                    [array addObject: [integerArray firstObject]];
                }
                zeroCount = 0 ;

                /// 判断是否是十到二十之间 第一个数

                    if (integerNumber == 2 && i == 0) {

                         NSString *number = [integer substringWithRange:NSMakeRange(0,2)];

                        if ([number intValue] <10 || [number intValue] >= 20) {
                            [array addObject:integerArray[[temp intValue]]];
                        }

                    }else{
                        [array addObject:integerArray[[temp intValue]]];
                    }


                if (![radices[modulus] isEqualToString:@""]) {
                    [array addObject:radices[modulus]];
                }


            }

            if ( modulus == 0 && zeroCount < 4 ) {

                if (![bigRadices[quotient] isEqualToString:@""]) {
                    [array addObject:bigRadices[quotient]];
                }

                zeroCount = 0;
            }
        }
    }
    if ([content containsString:@"."]) {

        [array addObject:@"tts_dot"];

    }


    if ([demical intValue] >= 0) {

        for (int i = 0;  i <demical.length; i ++) {

            NSString *temp = [demical substringWithRange:NSMakeRange(i,1)];
            NSString * str = [NSString stringWithFormat:@"tts_%@",[temp copy]];

            [array addObject:str];
        }

        if (demical.length == 2) {
            NSString * first = [demical substringWithRange:NSMakeRange(0, 1)];
            NSString * last = [demical substringWithRange:NSMakeRange(1, 1)];

            if ([first isEqualToString:last]) {

                [array removeLastObject];

                [array addObject:[NSString stringWithFormat:@"tts_%@_copy",first]];

            }
        }
    }
}

+ (NSDictionary *)getNumberDictFromContent:(NSString *)str {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *contentArr = [str componentsSeparatedByString:@"，"];
    NSString *accountStr = contentArr.firstObject;
    NSString *couponStr = contentArr.lastObject;
    NSString *accountMoney;
    if ([accountStr containsString:@"易来米到账"]) {
        accountMoney = [str substringWithRange:NSMakeRange(5,accountStr.length-1 - 5)];
    }else if ([accountStr containsString:@"会员充值"]){
        accountMoney = [str substringWithRange:NSMakeRange(4,accountStr.length-1 - 4)];//str2 = "is"
    } else if ([accountStr containsString:@"会员消费"]){
        accountMoney = [str substringWithRange:NSMakeRange(4,accountStr.length-1 - 4)];//str2 = "is"
    }
    [dic setValue:accountMoney forKey:@"account"];
    NSString *couponMoney = [couponStr substringWithRange:NSMakeRange(2,couponStr.length-1 - 2)];
    [dic setValue:couponMoney forKey:@"coupon"];
    return dic;
}


+ (NSMutableArray *)caluateMoney:(NSString *)content {

    NSString * integer = @"";
    NSString * demical = @"";
    NSMutableArray * array = [NSMutableArray array];
    NSString *money = [self getNumberFromStr:content];
    NSArray * moneyArray = [money componentsSeparatedByString:@"."];
    NSArray * integerArray = @[@"tts_0",@"tts_1",@"tts_2",@"tts_3",@"tts_4",@"tts_5",@"tts_6",@"tts_7",@"tts_8",@"tts_9"];
    NSArray * radices = @[@"", @"tts_ten", @"tts_hundred", @"tts_thousand"];
    NSArray * bigRadices = @[@"", @"tts_ten_thousand", @"tts_ten_million"];

    if (moneyArray.count == 1) {
        integer = [moneyArray firstObject];
    }else{
        integer = moneyArray.firstObject;
        demical = moneyArray.lastObject;
    }

    if ([content containsString:@"易来米到账"]) {

        [array addObject:@"tts_pre"];

    }else if ([content containsString:@"会员充值"]) {
        [array addObject:@"huiyuanchongzhi"];

    }else if ([content containsString:@"会员消费"]){

        [array addObject:@"huiyuanxiaofei"];
    }

    if ([integer intValue] == 0) {
        [array addObject:@"tts_0"];
    }

    if ([integer intValue] >0) {

        NSInteger zeroCount = 0;

        NSInteger integerNumber = integer.length % 4;

        for (int i = 0; i < integer.length; i++) {

            NSInteger p       = integer.length -1 - i;
            NSInteger modulus = p % 4;
            NSInteger quotient = (int)(p / 4);
            NSString *temp = [integer substringWithRange:NSMakeRange(i,1)];

            if ([temp isEqualToString:@"0"] ) {
                zeroCount ++;

            }else{
                if (zeroCount > 0) {
                    [array addObject: [integerArray firstObject]];
                }
                zeroCount = 0 ;

                /// 判断是否是十到二十之间 第一个数

                    if (integerNumber == 2 && i == 0) {

                         NSString *number = [integer substringWithRange:NSMakeRange(0,2)];



                        if ([number intValue] <10 || [number intValue] >= 20) {
                            [array addObject:integerArray[[temp intValue]]];
                        }

                    }else{
                        [array addObject:integerArray[[temp intValue]]];
                    }


                if (![radices[modulus] isEqualToString:@""]) {
                    [array addObject:radices[modulus]];
                }


            }

            if ( modulus == 0 && zeroCount < 4 ) {

                if (![bigRadices[quotient] isEqualToString:@""]) {
                    [array addObject:bigRadices[quotient]];
                }

                zeroCount = 0;
            }
        }
    }
    if ([content containsString:@"."]) {

        [array addObject:@"tts_dot"];

    }


    if ([demical intValue] >=0) {

        for (int i = 0;  i <demical.length; i ++) {

            NSString *temp = [demical substringWithRange:NSMakeRange(i,1)];
            NSString * str = [NSString stringWithFormat:@"tts_%@",[temp copy]];

            [array addObject:str];
        }

        if (demical.length == 2) {
            NSString * first = [demical substringWithRange:NSMakeRange(0, 1)];
            NSString * last = [demical substringWithRange:NSMakeRange(1, 1)];

            if ([first isEqualToString:last]) {

                [array removeLastObject];

                [array addObject:[NSString stringWithFormat:@"tts_%@_copy",first]];

            }
        }
    }

    if ([money floatValue] == 0) {
        return nil;
    }

    [array addObject:[NSString stringWithFormat:@"%@",@"tts_yuan"]];
    
    NSMutableArray *temArr = [NSMutableArray array];
    for (NSString *key in array) {
        [temArr addObject:[NSString stringWithFormat:@"%@.mp3", key]];
    }

    return temArr;

}

+ (NSString *)getNumberFromStr:(NSString *)str

{
    NSString *changeStr;
    if ([str containsString:@"易来米到账"]) {
        changeStr = [str substringWithRange:NSMakeRange(5,str.length-1 - 5)];
    } else if ([str containsString:@"会员充值"]){
        changeStr = [str substringWithRange:NSMakeRange(4,str.length-1 - 4)];//str2 = "is"

    } else if ([str containsString:@"会员消费"]){
        changeStr = [str substringWithRange:NSMakeRange(4,str.length-1 - 4)];//str2 = "is"
    }
    return changeStr;
}

@end
