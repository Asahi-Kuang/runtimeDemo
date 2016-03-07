# iOS Objective-C runtime system learning
##[Apple developer document of runtime](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtHowMessagingWorks.html)

###一、At first, I have to import the library `<objc/runtime.h>`
#### PS. If I call the function `objc_msgSend(target, SEL, parameters)` directly. There will be a warning message `Implicitly declaring library function 'objc_msgSend' with type 'id(id, SEL, ...)'`. To solve this problem, I have to do blow: 
#### 1. import a library to the project `<objc/message.h>`.
then, there will be another error: `Too many arguments to function call, expected 0, have 3.`
#### 2. go to the project setting -> Build Setting, and find the item `Enable Strict Checking of objc_msgSend Calss`, then changing it's value to `NO` will make everything be ok.

![pic url](http://a1.qpic.cn/psb?/V106iJhq3r5pvo/b.cAqj29KZxgazPBQhIHUKw5YDt9KXPGtlz6JAWiI4c!/b/dIwBAAAAAAAA&bo=ngLpAJ4C6QAFACM!&rf=viewer_4)

---

###二、Notes of learning runtime system.
####What is runtime, how it works and what is it's function:

######The objective-c defers as many desicions as it can from compile time and linked time to runtime.Whenever possible,it does things dynamically.That means the language requires not only compiler, but also a runtim system. runtime system makes the language work.

######runtime have two versions. one is legacy version(for Objective-C 1.0, run at 32bit system), another is modern version(for Objective-C 2.0, run at 64 bit system).

#####There are three levels to use runtime:
1. **Objective-C source code:** just use objectvie-c's source code,runtime will run automaticlly.
2. **NSObject Methods:**
3. **Runtime Functions:**: use runtime functions directly.like `objc_msgSend()`.At first, I have to import header file`<objc/runtime.h>`.

######In Objective-C, messages can't be bound to method implementations until runtime.Runtime converts the message from `[receiver message]` to runtime function `objc_msgSend()`.The function takes the receiver and the message(a selector) as its two parameters`objc_msgSend(receiver, selector)`.Also, the function handle all the arguments of message`objc_msgSend(receiver, selector, argu1, argu2, ...)`.


#####messaging function do everything necessary for dynamic binding:
1. Find the procedure(method implementation) that she selector refers to.Since the same method can be implemented differently by separate classes,it finds precise(精确的) procedure that depends on the class of the receiver.
2. Call the procedure, passing receving object(a pointer of its data), along with the arguments defined in the method.
3. Pass the return value of the procedure as its own return value.

**ps. The compiler calls the messaging function.You should never call it directly in your code.**

#####The key to messaging lies in the structures that compiler builds for each for every class and object.Every class structure has two essential elements:
a. A pointer to the superclass.
b. A `class dispath table`: the table has entries that associated the method selectors with the address of the method.

when a object is created, memory for it is allocated and its instanc variables is initialized.the pointer,called `isa`, gives the object access to its class, through the class, to all classes that it inherits from.

![pic url](http://a2.qpic.cn/psb?/V106iJhq3r5pvo/7*Ig4AGlBrVoOafKQlORWClufg3cqZMWjJsrJqDsHoo!/b/dG8BAAAAAAAA&bo=TAEgAkwBIAIBASY!&rf=viewer_4)

######**when a message is sent to the object, the function of fllowing the object's `isa` pointer to the class structure where it can look up the method selector in the `dispath table`.If it can't find the selector, objc_msgSend follows the poiter to the superclass will try to find the selector in its `dispath table`.it never stop until it reaches the `NSObject` class. This is the way that method implementations are chosen at runtime. That methods are dynamically bound to message.**

#####To speed the messaging process.the runtime system caches(缓存) the selectors and address of methods as they are used.


####Using hidden arguments
######the `objc_msgSend`also passes two hidden arguments to the procedure it finds.
1. the receving object. use `self`.
2. the selector for the method. use `_cmd`.

example:

```
- strange {
	id target = getTheReceiver();
	SEL method = getTheMethod();
	if(target == self || method == _cmd)
		return nil;
	return [target performSelector:method]l
}
```
**`self` is more useful of the two arguments.It is, in fact, the way the receving object's instance variables are made available to the method definition.**






