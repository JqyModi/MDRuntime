//
//  MDRuntimeController.swift
//  MDRuntime
//
//  Created by Mac on 2018/4/1.
//  Copyright © 2018年 Mac. All rights reserved.
//

import UIKit

class MDRuntimeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(white: 0.93, alpha: 1.0)
//        getClassInfo()
        
//        dynamicCreateCls()
        
        associatedObjectUse()
    }

    //运行时练习
    func testRuntime() -> Void {
        
        debugPrint("testStart")
        //运行时创建RuntimeModel类
        let mdRuntimeCls = objc_allocateClassPair(RuntimeModel.self, "MDRuntimeClass", 0)
        
        
        //注册创建的对象
        objc_registerClassPair(mdRuntimeCls!)
        debugPrint("testEnd")
        //销毁创建的对象
        objc_disposeClassPair(mdRuntimeCls!)
    }
    
    //成员变量操作
    func ivarOperation() -> Void {
        /*C 用结构体定义如下
        struct ivar_t {
            #if __x86_64__
            // *offset was originally 64-bit on some x86_64 platforms.
            // We read and write only 32 bits of it.
            // Some metadata provides all 64 bits. This is harmless for unsigned
            // little-endian values.
            // Some code uses all 64 bits. class_addIvar() over-allocates the
            // offset for their benefit.
            #endif
            int32_t *offset;
            const char *name;
            const char *type;
            // alignment is sometimes -1; use alignment() instead
            uint32_t alignment_raw;
            uint32_t size;
            
            uint32_t alignment() const {
            if (alignment_raw == ~(uint32_t)0) return 1U << WORD_SHIFT;
            return 1 << alignment_raw;
            }
        };
        */
    }
    
    //属性操作
    func propertyOperation() -> Void {
        /*C 用结构体定义如下
        struct property_t {
            const char *name;
            const char *attributes;
        };
         
         /// Defines a property attribute
         public struct objc_property_attribute_t {
         
         /**< The name of the attribute */
         public var name: UnsafePointer<Int8>
         
         /**< The value of the attribute (usually empty) */
         public var value: UnsafePointer<Int8>
         }
        */
        
        
    }
    
    //关联对象的使用:可以动态地增强类现有的功能：如给UIView对象添加手势操作
    func associatedObjectUse() -> Void {
        //获取一个关联对象
        var aOKey = "AOKEY"
        let ao = objc_getAssociatedObject(self, &aOKey)
        debugPrint("ao ----->> \(ao)")
        debugPrint("============================================")
        let btn = UIButton()
        btn.tag = 66
        //设置一个关联对象
        objc_setAssociatedObject(self, &aOKey, btn, .OBJC_ASSOCIATION_RETAIN)
        
        //获取绑定的关联对象
        let btnObj = objc_getAssociatedObject(self, &aOKey)
        debugPrint("btnObj ----->> \(btnObj)")
        //移除关联对象
        objc_removeAssociatedObjects(self)
    }
    
    func dynamicCreateCls() -> Void {
        debugPrint("start ")
        
        //运行时创建RuntimeModel类
        let mdRuntimeCls = objc_allocateClassPair(RuntimeModel.self, "MDRuntimeClass", 0)
        //为类添加成员变量
        class_addIvar(mdRuntimeCls, "color", String().lengthOfBytes(using: String.Encoding.utf8), 1, "i")
        //为类添加属性
        let time = objc_property_attribute_t(name: "time", value: "20180404")
        let type = objc_property_attribute_t(name: "runtime", value: "runtime demo ~")
        let attrs = [time, type]
        class_addProperty(mdRuntimeCls, "props", attrs, 2)
        
        //通过当前类获取到changeColor的IMP指针
        let c = self.classForCoder
        let changeColorIMP = class_getMethodImplementation(c, Selector.init("changeColor"))
        
        //为类添加方法
        class_addMethod(mdRuntimeCls, "changeColor", changeColorIMP!, "v@:")
        
        //注册创建的类：不是自定义的类系统默认注册
        objc_registerClassPair(mdRuntimeCls!)
        
        //使用该类:创建该类方式一：
//        let instance = mdRuntimeCls?.alloc()
//        //执行新添加的方法
//        instance?.perform(Selector.init("changeColor"))
//        debugPrint("instance ---> \(instance?.description)")
        
        //使用该类:创建该类方式二：
        let instance = class_createInstance(mdRuntimeCls, 0) as! AnyObject
        //执行新添加的方法
        instance.perform(Selector.init("changeColor"))
        debugPrint("instance ---> \(instance.description)")
        
        //使用新添加的成员变量
        let colorIvar = class_getInstanceVariable(mdRuntimeCls, "color")
        
//        object_setIvar(instance, colorIvar!, "red")
        //需要通过Strong指针来设置变量的值否则会报错
        object_setIvarWithStrongDefault(instance, colorIvar!, "blue")
        //获取添加的成员变量的值
        let color = object_getIvar(instance, colorIvar!)
        debugPrint("color ---> \(color.debugDescription)")
        debugPrint("end ")
        //销毁创建的对象
//        objc_disposeClassPair(mdRuntimeCls!)
        
        //输出动态创建的类包含哪些属性
        debugPrint("============================================")
        getClassInfo(cls: mdRuntimeCls!)
        debugPrint("============================================")
        
        //操作对象的类一些函数使用
        //获取对象的类名
        let clsName = object_getClassName(instance)
        debugPrint("clsName -----> \(String.init(utf8String: clsName))")
        debugPrint("============================================")
        //获取对象的类
        let oCls = object_getClass(instance)
        debugPrint("oCls ------> \(oCls)")
        debugPrint("============================================")
        //设置对象的类
        object_setClass(instance, UIView.self)
        //再次获取类的信息:已经变成了UIView的类信息
//        getClassInfo(cls: object_getClass(instance)!)
        
        //获取类定义
        //获取系统已注册的类列表
        getRegistedClsesOfSystem()
    }
    
    //获取系统已注册的所以类
    func getRegistedClsesOfSystem() {
        var typeCount = Int(objc_getClassList(nil, 0))
        //Swift方式分配指定大小的内存空间给types:指针
        let  types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleaseintTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        
        typeCount = Int(objc_getClassList(autoreleaseintTypes, Int32(typeCount)))
        if typeCount > 0 {
            debugPrint("当前系统注册的类数量为：\(typeCount)")
            debugPrint("============================================")
            //开始输出这些类
            debugPrint("anyCls ----> \(String(describing: types))")
            for i in (0..<typeCount) {
                let iCls = autoreleaseintTypes[i]
                debugPrint("iCls ----> \(iCls)")
            }
            debugPrint("============================================")
        }
        //释放手动分配的内存空间
        types.deallocate(capacity: typeCount)
        
        //获取方式二：
        var outCount: UInt32 = 0
        let tempClses = objc_copyClassList(&outCount)
        //自动释放
//        free(tempClses)
    }
    
    @objc func changeColor() -> Void {
        debugPrint("changeColor ~")
    }
    
    
    //运行时动态获取实例对象的变量，属性，方法(实例方法)等信息
    func getClassInfo(cls: AnyClass) {
//        let model = RuntimeModel()
//        let cls = model.classForCoder
        
        //记录当前成员变量数量
        var outCount: UInt32 = 0
        
        //类名
        let clsName = class_getName(cls)
//        debugPrint("clsName ---> \(clsName)")  //打印的是地址
        debugPrint("clsName1 ---> "+String.init(cString: clsName)) //打印的是字符串
        debugPrint("============================================")
        //父类
        let superClsName = class_getName(class_getSuperclass(cls))
//        debugPrint("superClsName ---> \(superClsName)")
        debugPrint("superClsName ---> "+String.init(cString: superClsName))
        debugPrint("============================================")
        //是否是元类
        let isMetaCls = class_isMetaClass(cls)
        debugPrint("cls is MetaCls? \(isMetaCls)")
        debugPrint("============================================")
        //变量实例大小
        let instanceSize = class_getInstanceSize(cls)
        debugPrint("instanceSize ---> \(instanceSize)")
        debugPrint("============================================")
        //成员变量
        //获取该对象的成员变量列表
        let ivars = class_copyIvarList(cls, &outCount) //获取到数组形式的一个链表用完需要手动释放
        //遍历所以成员变量
        for i in (0..<outCount) {
            let ivar = ivars![Int(i)]
//            debugPrint("cls instance variable's name: \(ivar_getName(ivar)) at index: \(i)")
            debugPrint("cls instance variable's name: \(String.init(cString: ivar_getName(ivar)!)) at index: \(i)")
        }
        debugPrint("============================================")
        
        //释放链表
        free(ivars)
        
        //获取具体的成员变量
        let vNm = class_getInstanceVariable(cls, "_modelName")
        if vNm != nil {
            debugPrint("mN 具体变量（名）：\(String.init(cString: ivar_getName(vNm!)!))")
        }else {
            debugPrint("mN 具体变量（名）：不存在~")
        }
        
        debugPrint("============================================")
        
        //属性操作
        let properties = class_copyPropertyList(cls, &outCount)
        for i in (0..<outCount){
            let pro = properties![Int(i)]
            debugPrint("cls instance property's name: \(String.init(cString: property_getName(pro))) at index: \(i)")
        }
        debugPrint("============================================")
        //获取具体的属性
        let pNm = class_getProperty(cls, "modelName")
        if pNm != nil {
            debugPrint("pNm 具体属性（名）：\(String.init(cString: property_getName(pNm!)))")
        }else {
            debugPrint("pNm 具体属性（名）：不存在~")
        }
        debugPrint("============================================")
        //方法操作
        let methods = class_copyMethodList(cls, &outCount)
        for i in 0..<outCount {
            let medthod = methods![Int(i)]
            debugPrint("cls instance method's name: \(method_getName(medthod).description) at index: \(i)")
        }
        debugPrint("============================================")
        
        //释放链表
        free(methods)
        
        //获取具体的对象方法
        let methodD = class_getInstanceMethod(cls, Selector.init("copyWithZone:"))
        if methodD != nil {
            debugPrint("methodD 具体对象方法（名）：\(method_getName(methodD!).description)")
        }else {
            debugPrint("methodD 具体对象方法（名）：不存在~")
        }
        debugPrint("============================================")
        //获取方法的实现具体：可调用
        let imp = class_getMethodImplementation(cls, Selector.init("copyWithZone:"))
        //通过具体实现调用该方法
        imp
        
        //获取具体的类方法
        let methodDe = class_getClassMethod(cls, Selector.init("clsMethod1"))
        if methodDe != nil {
            debugPrint("methodDe 具体类方法（名）：\(method_getName(methodDe!).description)")
        }else {
            debugPrint("methodDe 具体类方法（名）：不存在~")
        }
        debugPrint("============================================")
        //获取方法的实现具体：可调用
        let clsMedImp = class_getMethodImplementation(cls, Selector.init("clsMethod1"))
        //通过具体实现调用该方法
        debugPrint("clsMedImp ----> \(clsMedImp)")
        debugPrint("============================================")
        
        //判断该类是否实现了该方法
        let isResponseSel = class_respondsToSelector(cls, Selector.init("objMethod1"))
        debugPrint("判断该类是否实现了该objMethod1方法：\(isResponseSel)")
        debugPrint("============================================")
        //协议操作
        let protocols = class_copyProtocolList(cls, &outCount)
        for i in 0..<outCount {
            let proto = protocols![Int(i)]
            debugPrint("cls instance protocol's name: \(String.init(cString: protocol_getName(proto))) at index: \(i)")
        }
        //释放链表:协议类别系统会自动释放
//        free(protocols)
        //判断该类是否实现了该协议
        let isResponsePro = class_conformsToProtocol(cls, NSCopying.self)
        debugPrint("判断该类是否实现了该NSCopying协议：\(isResponseSel)")
        debugPrint("============================================")
    }
}
