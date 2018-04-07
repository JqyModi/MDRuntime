//
//  RuntimeModel.swift
//  MDRuntime
//
//  Created by Mac on 2018/4/1.
//  Copyright © 2018年 Mac. All rights reserved.
//

import UIKit

class RuntimeModel: NSObject, NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        debugPrint("copyWithZone")
        return self
    }
    

    @objc var modelName: String?
    @objc static var staticVar: String?
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init()
//        self.modelName = "MDRuntimeModelName"
//        debugPrint("initCoder")
//    }
//
//    func encode(with aCoder: NSCoder) {
//        debugPrint("encode")
//    }
    
    //定义一个实例方法
    @objc func objMethod1() -> Void {
        debugPrint("call无参数对象方法 ----> \(#function)")
    }
    
    @objc dynamic func objMethod2(str: String) -> Void {
        debugPrint("call带参数对象方法 ----> \(#function)")
    }
    
    //定义一个静态方法
    @objc dynamic static func staticMethod1() -> Void {
        debugPrint("call ----> \(#function)")
    }
    
    //定义一个类方法
    @objc dynamic class func clsMethod1() -> Void {
        debugPrint("call ----> \(#function)")
    }
    
    
}
