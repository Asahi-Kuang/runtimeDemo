//
//  Model.h
//  NSCoder
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/6.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject<NSCoding>

@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *gender;
@property (nonatomic, assign)NSInteger age;

@end
