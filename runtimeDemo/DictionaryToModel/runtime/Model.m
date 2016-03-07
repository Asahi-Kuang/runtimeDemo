//
//  Model.m
//  runtime
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/4.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import "Model.h"
#import <objc/runtime.h>

@implementation Model
- (instancetype)initWithDataDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        //
        if (![self getMapDictionary]) {
            [self assignValueToModelWithNoMapDictionary:dict];
        }
        else {
            [self assignValueToModelWithDictionary:dict];
        }
    }
    return self;
}

// 便利构造
+ (instancetype)modelWithDictionary:(NSDictionary *)dict{
    return [[self alloc] initWithDataDictionary:dict];
}

// 取得getter方法
- (SEL)createGetterMethodWithPropertyName:(NSString *)name{
    return NSSelectorFromString(name);
}

// 取得所有的成员变量
- (NSArray *)getAllProperties {
    NSMutableArray *array = [NSMutableArray array];
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (unsigned int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        const char *propertyString = property_getName(property);
        NSString *string = [NSString stringWithUTF8String:propertyString];
        [array addObject:string];
    }
    free(properties);
    return array;
}

// 通过方法和类的签名来调用对象。实现取值
- (void)displayProperty {
    // 取得所有成员变量
    NSArray *properties = [self getAllProperties];
    for (int i = 0; i < [properties count]; i ++) {
        // 取得getter
        SEL getSel = [self createGetterMethodWithPropertyName:properties[i]];
        
        if ([self respondsToSelector:getSel]) {
            // 获取类和方法签名
            NSMethodSignature *signature = [self methodSignatureForSelector:getSel];
            // 从签名获得调用对象
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            
            // 添加target
            [invocation setTarget:self];
            
            // 添加selector
            [invocation setSelector:getSel];
            
            // 设置接收返回的值
            NSObject *__unsafe_unretained returnValue = nil;
            
            // 调用
            [invocation invoke];
            
            // 接收返回值
            [invocation setReturnValue:&returnValue];
            
        }
    }
}

- (NSDictionary *)getMapDictionary {
    return @{@"姓名":@"name", @"性别":@"gender"};
}

@end
