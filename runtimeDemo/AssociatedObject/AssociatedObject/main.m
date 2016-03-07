//
//  main.m
//  AssociatedObject
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/7.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+AssociatedObject.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *object = [NSObject new];
        [object setNewProperty:@"Hello World"];
        NSString *result = object.newProperty;
        NSLog(@"%@", result);
    }
    return 0;
}
