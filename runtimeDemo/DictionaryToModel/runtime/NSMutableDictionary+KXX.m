//
//  NSMutableDictionary+KXX.m
//  runtime
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/4.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import "NSMutableDictionary+KXX.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (KXX)
- (void)newMethodSetObject:(id)object forKey:(NSString *)key{
    if (!key) {
        NSLog(@"nil 已被处理!!!");
        return;
    }
    [self newMethodSetObject:object forKey:key];
}

+ (void)load {
    Method _origin = class_getInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(setObject:forKey:));
    Method _new = class_getInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(newMethodSetObject:forKey:));
    method_exchangeImplementations(_origin, _new);
    

}
@end
