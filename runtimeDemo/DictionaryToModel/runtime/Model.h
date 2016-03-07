//
//  Model.h
//  runtime
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/4.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import "ModelBaseClass.h"

@interface Model : ModelBaseClass
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *gender;

- (instancetype)initWithDataDictionary:(NSDictionary *)dict;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
// 取得getter方法
- (SEL)createGetterMethodWithPropertyName:(NSString *)name;
- (NSArray *)getAllProperties;
- (void)displayProperty;
- (NSDictionary *)getMapDictionary;
@end
