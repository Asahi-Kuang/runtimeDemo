//
//  ModelBaseClass.m
//  runtime
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/4.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import "ModelBaseClass.h"

@implementation ModelBaseClass
// 构建setter方法
- (SEL)createSetterMethodWithPropertyName:(NSString *)name {
    if (!name) {
        return nil;
    }
    // 首字母大写。
    name = [NSString stringWithFormat:@"set%@:", name.capitalizedString];
    
    // 生成setter方法。
    return NSSelectorFromString(name);
}

// 字典转模型。这是没有字典映射的，数据字典的key必须和model的成员变量一致。
- (void)assignValueToModelWithNoMapDictionary:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    // 取出所有的key
    NSArray *keys = [dict allKeys];
    
    for (int i = 0; i < [keys count]; i ++) {
        // 生成selector
        SEL setSel = [self createSetterMethodWithPropertyName:keys[i]];
        if ([self respondsToSelector:setSel]) {
            NSString *value = [NSString stringWithFormat:@"%@", dict[keys[i]]];
            [self performSelectorOnMainThread:setSel withObject:value waitUntilDone:YES];
        }
    }
}

// 这是有字典映射的。
- (void)assignValueToModelWithDictionary:(NSDictionary *)dict {
    // 取得映射字典。
    NSDictionary *mapDict = [self getMapDictionary];
    
    // 转换成key和数据字典一样的字典。
    NSArray *dataDictKeys = [dict allKeys];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    for (int i = 0; i < [dataDictKeys count]; i ++) {
        NSString *key = dataDictKeys[i];
        [tempDict setValue:dict[key] forKey:mapDict[key]];
    }
    
    [self assignValueToModelWithNoMapDictionary:tempDict];
}

// 获取字典映射，返回nil是为了子类重写该方法。
- (NSDictionary *)getMapDictionary {
    return nil;
}
@end
