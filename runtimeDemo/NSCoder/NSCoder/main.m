//
//  main.m
//  NSCoder
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/6.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Model *model = [Model new];
        model.name = @"kxx";
        model.age = 24;
        model.gender = @"male";
        
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"modelData.data"];
        
        // 归档
        BOOL flag = [NSKeyedArchiver archiveRootObject:model toFile:path];
        if (flag) {
            NSLog(@"archive object successfully!!!");
        }
        
        
        
        // 解档
        Model *unarchivedModel = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        NSLog(@"\n\n%@\n%@\n%ld", unarchivedModel.name, unarchivedModel.gender, unarchivedModel.age);
    }
    return 0;
}
