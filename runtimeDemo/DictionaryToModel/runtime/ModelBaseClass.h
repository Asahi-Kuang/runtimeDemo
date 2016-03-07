//
//  ModelBaseClass.h
//  runtime
//
//  Created by Kxx.xxQ 一生相伴 on 16/3/4.
//  Copyright © 2016年 Asahi_Kuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelBaseClass : NSObject
- (SEL)createSetterMethodWithPropertyName:(NSString *)name;
- (void)assignValueToModelWithNoMapDictionary:(NSDictionary *)dict;
- (void)assignValueToModelWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)getMapDictionary;
@end
