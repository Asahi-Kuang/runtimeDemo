//
//  main.m
//  runtime
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/4.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "NSMutableDictionary+KXX.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSDictionary *mockDict = @{@"姓名":@"邝大爷", @"性别":@"Male", @"这个没有":@"(づ｡◕‿‿◕｡)づ"};
        Model *model = [Model modelWithDictionary:mockDict];
        NSLog(@"%@\n------>\n%@\n", model.name, model.gender);
    }
    return 0;
}
