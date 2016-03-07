//
//  NSObject+AssociatedObject.m
//  AssociatedObject
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/7.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import "NSObject+AssociatedObject.h"
#import <objc/runtime.h>

static const void *uniqueKey = "newPropertyKey";
@implementation NSObject (AssociatedObject)
@dynamic newProperty;

// setter
- (void)setNewProperty:(id)newProperty {
    objc_setAssociatedObject(self, uniqueKey, newProperty, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// getter
- (id)newProperty {
    return objc_getAssociatedObject(self, uniqueKey);
}
@end
