//
//  Model.m
//  NSCoder
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/6.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import "Model.h"
#import <objc/runtime.h>

const char *uniqueKey = "objectKey";

@implementation Model

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        //
        
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        for (int i = 0; i < count; i ++) {
            objc_property_t property = properties[i];
            const char *propertyChar = property_getName(property);
            NSString *propertyString = [NSString stringWithUTF8String:propertyChar];
            id value = [aDecoder decodeObjectForKey:propertyString];
            [self setValue:value forKey:propertyString];
        }
        free(properties);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        const char *propertyChar = property_getName(property);
        NSString *propertyString = [NSString stringWithUTF8String:propertyChar];
        id object = [self valueForKey:propertyString];
        [aCoder encodeObject:object forKey:propertyString];
    }
    free(properties);
}


@end
