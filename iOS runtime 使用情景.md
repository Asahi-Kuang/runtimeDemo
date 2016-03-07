# iOS runtime 使用情景
####runtime 常用的情景有：
1. 动态(dynamic)调换(exchange)两个方法(method)的执行(implementation)。常用于类别中(catagory)。
2. 动态遍历类所有的成员变量(property)，实现数据字典(Dictionary)快速转实体类(模型)。常用于数据-模型处理。
3. 动态遍历类所有的成员变量(property)，实现归档(encode)与解档(decode)。
4. 动态关联。可以给分类新增成员变量。(分类本是不允许添加成员变量的。)

###runtime的使用：
####一、动态调换方法：
**NSMutableArray**有个自带的方法`addObject:(id)object`,这个参数object是不能为nil的，如果这样调用`[array addObject:nil]`，程序会无情crash。我要实现就算添加了`nil`，程序也不会crash。

1. 新建类别(NSMutableArray+KXX),并在`NSMutableArray+KXX.m`文件中导入头文件`<objc/runtime.h>`。
2. 在`NSMutableArray+KXX.m`文件中,实现方法`- (void)newMethodToAddObject:(id)objdect`。

```
- (void)newMethodToAddObject:(id)object {
    if (!object) {
        NSLog(@"object为空,已被处理!!!");
    }
}
```

3. 在`NSMutableArray+KXX.m`文件中,实现方法`+ (void)load`。这个方法会在对象内存被分配、初始化后就自动调用。

```
+ (void)load {
	// NSMutableArray 真正的类名是 __NSArrayM!!!! NSMutableDictionary同理。
    Method _originMethod = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(addObject:));
    Method _newMethod = class_getInstanceMethod([self class], @selector(newMethodToAddObject:));
    // 调换两个方法的执行
    method_exchangeImplementations(_originMethod, _newMethod);
}
```

4. 在`main.m`文件测试。

```
#import "NSMutableArray+KXX.h"
#import <objc/runtime.h>

@implementation NSMutableArray (KXX)
- (void)newMethodToAddObject:(id)object {
    if (!object) {
        NSLog(@"object为空,已被处理!!!");
    }
}

+ (void)load {
    // NSMutableArray 真正的类名是 __NSArrayM。NSMutableDictionary同理。
    Method _originMethod = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(addObject:));
    Method _newMethod = class_getInstanceMethod([self class], @selector(newMethodToAddObject:));
    // 调换两个方法的执行
    method_exchangeImplementations(_originMethod, _newMethod);
    
}
@end
```
运行后虽然有警告，但是不会crash.输出为
`2016-03-04 20:02:53.101 runtime[55523:513861] object为空,已被处理!!!
Program ended with exit code: 0`


####二、字典转实体(模型)
从网络上下载的json数据解析出字典后，可以利用`runtime`来快速转成实体类。而不用一个一个的给实体属性赋值。还有就是当数据字典的键(key)和实体的成员变量不一致时的处理，这个时候使用字典的映射(map)。

1.新建一个继承于`NSObject`的类`ModelBaseClass`，这个作为一会儿实体类的模型基类。
2.在基类构建`setter`方法。

```
// 构建setter方法
- (SEL)createSetterMethodWithPropertyName:(NSString *)name {
    if (!name) {
        return nil;
    }
    // 首字母大写。
    name = [NSString stringWithFormat:@"set%@:", name.capitalizedString];
    
    // 生成setter方法。
    return NSSelectorFromString(name);
}
```

3.构建获取映射字典方法

```
// 获取字典映射，返回nil是为了子类重写该方法。
- (NSDictionary *)getMapDictionary {
    return nil;
}
```

4.分情况如果是key不一样(需要映射字典)和key一样(其实也可以不用分，就按不一样处理)

```
// 字典转模型。这是没有字典映射的，数据字典的key必须和model的成员变量一致。
- (void)assignValueToModelWithNoMapDictionary:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    // 取出所有的key
    NSArray *keys = [dict allKeys];
    
    for (int i = 0; i < [keys count]; i ++) {
        // 生成selector
        SEL setSel = [self createSetterMethodWithPropertyName:keys[i]];
        if ([self respondsToSelector:setSel]) {
            NSString *value = [NSString stringWithFormat:@"%@", dict[keys[i]]];
            [self performSelectorOnMainThread:setSel withObject:value waitUntilDone:YES];
        }
    }
}
// 这是有字典映射的。
- (void)assignValueToModelWithDictionary:(NSDictionary *)dict {
    // 取得映射字典。
    NSDictionary *mapDict = [self getMapDictionary];
    
    // 转换成key和数据字典一样的字典。
    NSArray *dataDictKeys = [dict allKeys];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    for (int i = 0; i < [dataDictKeys count]; i ++) {
        NSString *key = dataDictKeys[i];
        [tempDict setValue:dict[key] forKey:mapDict[key]];
    }
    
    [self assignValueToModelWithNoMapDictionary:tempDict];
}
```

-
5.新建实体类`Model`，继承于`ModelBaseClass`。并导入头文件`<objc/runtime.h>`

6.在`Model.h`文件创建两个成员变量。

```
#import "ModelBaseClass.h"

@interface Model : ModelBaseClass
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *gender;
@end
```

7.完成构造方法。这里要分情况，是否需要字典映射。

```
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
```

8.创建生成`getter`方法

```
// 取得getter方法
- (SEL)createGetterMethodWithPropertyName:(NSString *)name{
    return NSSelectorFromString(name);
}
```

9.获取类的所有的成员变量。

```
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
```

10.通过类和方法的签名来获取调用对象。

```
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
```

11.重写父类的取得映射字典的方法。**这个字典的键就是数据字典的key，值就是类的成员变量。**

```
- (NSDictionary *)getMapDictionary {
    return @{@"姓名":@"name", @"性别":@"gender", @"这个没有":@"(づ｡◕‿‿◕｡)づ"};
}
```

12.如果数据字典的成员个数多余类的成员变量数量，就会造成`NSMutableDictionary`的`setObject:(id)object forKey:(NSString *)key`方法的object参数为`nil`，程序就会crash.为了解决这个问题，新建一个`NSMutableDictionary`的分类`NSMutableDictionary+KXX`.

```
#import "NSMutableDictionary+KXX.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (KXX)
- (void)newMethodSetObject:(id)object forKey:(NSString *)key{
    if (!key) {
        NSLog(@"nil 已被处理!!!");
    }
    [self newMethodSetObject:object forKey:key];
}

+ (void)load {
    Method _origin = class_getInstanceMethod(objc_getClass("__NSDictionaryM"), @selector(setObject:forKey:));
    Method _new = class_getInstanceMethod([self class], @selector(newMethodSetObject:forKey:));
    method_exchangeImplementations(_origin, _new);
}
@end
```

13.在`main.m`测试

```
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
```
成功！！！输出

```
2016-03-04 21:43:13.248 Model[63415:591984] Kxx.xxQ -----> Male
Program ended with exit code: 0
```



####三、归档和解档
如果需要实现一些基本数据的数据持久化(data persistance)或者数据共享(data share)。我们可以选择归档和解档。如果用一般的方法:

```
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"nameKey"];
    [aCoder encodeObject:self.gender forKey:@"genderKey"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.age] forKey:@"ageKey"];
}
```
也可以实现。但是如果实体类有很多的成员变量，这种方法很显然就无力了。
这个时候，我们就可以利用`runtime`来实现快速归档、解档:

1.让实体类遵循`<NSCoding>`协议。并在.m文件导入头文件`<objc/runtime.h>`。
2.实现`- (instancetype)initWithCoder:(NSCoder *)aDecoder`和`- (void)encodeWithCoder:(NSCoder *)aCoder`方法。

```
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
```

3.在`main.m`文件测试归档、解档。

```
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
```

4.控制台输出

```
2016-03-06 18:52:32.368 NSCoder[38672:320789] archive object successfully!!!
2016-03-06 18:52:32.369 NSCoder[38672:320789] 

kxx
male
24
Program ended with exit code: 0
```

5.查看路径文件会有一个数据文件存在：

![数据文件](https://github.com/Asahi-Kuang/picture/blob/master/data.png?raw=true)



####四、动态关联对象
比如`Objective-C`是不能向一个类的类别(catagory)添加新成员变量的。但是我们可以利用`runtime`来实现动态添加成员变量。先把关联策略列出来：

| Behavior | @property equivalent | Description |
|------------|---------------------------|---------------|
|OBJC_ASSOCIATION_ASSIGN|@property(assgin) or @property(unsafe_unretained)|弱引用|
|OBJC_ASSOCIATION_RETAIN_NONATOMIC|@property(nonatomic,strong)|强引用，线程不安全的|
|OBJC_ASSOCIATION_COPY_NONATOMIC|@property(nonatomic,copy)|可拷贝，线程不安全的|
|OBJC_ASSOCIATION_RETAIN|@property(atomic,strong)|强引用，线程安全的|
|OBJC_ASSOCIATION_COPY|@property(atomic,copy)|属性是可拷贝的，线程安全的|

#####模式：
1. 添加私有变量(private variables)来让方法执行更加完善。
2. 给类别(catagory)增加公共属性来配置它的行为。
3. 给`KVO`模式创建一个相关联的观察者(observer)。

######1. 给类别增加新的公共属性。
新建一个`NSObject`类的类别`NSObject+AssociatedObject`。
在`.h`文件新增一个成员变量:

```
@property (nonatomic, strong)id newProperty;
```
然后在`.m`文件的implementation下面加上关键字`@dynamic`，表示这个新增的成员变量是动态加载的。否则类别是不能使用新增成员变量的。并且导入头文件`<objc/runtime.h>`。

```
#import "NSObject+AssociatedObject.h"

@implementation NSObject (AssociatedObject)
@dynamic newProperty;

@end
```

设置全局的静态的一会儿关联对象要用的唯一的key值：

```
static const void *uniqueKey = "newPropertyKey";
```

然后就是设置新成员变量的`setter`方法。

**objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)**
参数说明：
`id object`：需要关联属性的对象。一般是`self`。
`const void *key`：这就是刚刚设置的唯一的key。
`id value`: 关联属性的值。
`objc_AssociationgPolicy policy`：关联策略。（详见上面表格）

```
// setter
- (void)setNewProperty:(id)newProperty {
    objc_setAssociatedObject(self, uniqueKey, newProperty, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
```

然后就是设置`getter`方法。

```
// getter
- (id)newProperty {
    return objc_getAssociatedObject(self, uniqueKey);
}
```

在`main.m`文件测试：

```
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
```

ok,输出:

```
2016-03-07 10:52:41.097 AssociatedObject[6237:58203] Hello World
Program ended with exit code: 0
```



