//
//  JsonParserNode.swift
//  VConvertor
//
//  Created by siu on 2022/3/16.
//

import Foundation

protocol JsonParserNode3Der {
    func transform2JsonParserNode2D(key: String?) -> JsonParserNode2D
}

/// 泛型 T 是对 value 值类型的描述, T 有可能是 String, Array<JsonParserNode3Der>, Dictionary<String, JsonParserNode3Der>
class JsonParserNode3D<T>: JsonParserNode3Der {
    
    var key = ""
    var value: T
    
    // 当 T 为 String 类型时, 为 nil
    var hierarchy: Int
    
    deinit {
        print("\(self) deinit")
    }
    
    init(with key: String, value: T, hierarchy: Int) where T == String {
        self.key = key
        self.value = value
        self.hierarchy = hierarchy
    }
    
    init(with key: String, value: T, hierarchy: Int) where T == Array<Any> {
        self.hierarchy = hierarchy
        self.key = key
        self.value = {
            var res = Array<JsonParserNode3Der>()
            value.enumerated().forEach { idx, v in
                if let v = v as? String {
                    let newInfo = JsonParserNode3D<String>.init(with: "\(key)_\(idx)", value: v, hierarchy: (hierarchy + 1))
                    res.append(newInfo)
                }
                if let v = v as? Array<Any> {
                    let newInfo = JsonParserNode3D<Array<Any>>.init(with: "\(key)_\(idx)", value: v, hierarchy: (hierarchy + 1))
                    res.append(newInfo)
                }
                if let v = v as? Dictionary<String, Any> {
                    let newInfo = JsonParserNode3D<Dictionary<String, Any>>.init(with: "\(key)_\(idx)", value: v, hierarchy: (hierarchy + 1))
                    res.append(newInfo)
                }
            }
            return res
        }()
    }
    
    init(with key: String, value: T, hierarchy: Int) where T == Dictionary<String, Any> {
        self.key = key
        self.hierarchy = hierarchy
        self.value = {
            var res = Dictionary<String, JsonParserNode3Der>()
            value.forEach { k, v in
                if let v = v as? String {
                    let newInfo = JsonParserNode3D<String>.init(with: k, value: v, hierarchy: (hierarchy + 1))
                    res[k] = newInfo
                }
                if let v = v as? Dictionary<String, Any> {
                    let newInfo = JsonParserNode3D<Dictionary<String, Any>>.init(with: k, value: v, hierarchy: (hierarchy + 1))
                    res[k] = newInfo
                }
                if let v = v as? Array<Any> {
                    let newInfo = JsonParserNode3D<Array<Any>>.init(with: k, value: v, hierarchy: (hierarchy + 1))
                    res[k] = newInfo
                }

            }
            return res
        }()
    }
            
    func transform2JsonParserNode2D(key: String?) -> JsonParserNode2D {
        let res = JsonParserNode2D()
        res.key = key ?? self.key
        if let dict = self.value as? Dictionary<String, JsonParserNode3Der> {
            res.items = []
            dict.forEach { k, v in
                let newItem = v.transform2JsonParserNode2D(key: k)
                newItem.fold = false
                newItem.hierarchy = self.hierarchy + 1
                res.items?.append(newItem)
            }
        }
        if let arr = self.value as? Array<JsonParserNode3Der> {
            res.items = []
            arr.forEach { elem in
                let newItem = elem.transform2JsonParserNode2D(key: nil)
                newItem.fold = false
                newItem.hierarchy = self.hierarchy + 1
                res.items?.append(newItem)
            }
        }
        if let str = self.value as? String {
            res.stringValue = str
            res.hierarchy = self.hierarchy + 1
            return res
        }
        res.items?.sort(by: {
            $0.key < $1.key
        })
        var pervious: JsonParserNode2D? = nil
        res.items?.forEach({
            $0.pervious = pervious
            pervious?.next = $0
            pervious = $0
            $0.parent = res
        })
        return res
    }
}

/// 与上面 JsonParserNode3D 比较, 少了 Dictionary 这一结构, 将 Dictionary 都转换为 数组
class JsonParserNode2D {
    
    let id: String
    var key = ""
    var stringValue: String?
    var items: [JsonParserNode2D]?
    var hierarchy: Int = 0
    var fold: Bool?
    weak var parent: JsonParserNode2D?
    weak var next: JsonParserNode2D?
    weak var pervious: JsonParserNode2D?
    
    init() {
        self.id = UUID().uuidString
    }
    
    /// 找出 hierarchy 最大值
    lazy var deep: Int = {
        var res = 0
        if let items = self.items {
            items.forEach({
                let tmp = $0.deep
                res = tmp > res ? tmp : res
            })
        }else{
            res = self.hierarchy > res ? self.hierarchy : res
        }
        return res
    }()
    
    /// 遍历所有子树, 统计 items 总量, 包含了根节点
    func numberOfAllItems() -> Int {
        var res = 0
        guard let items = self.items else {
            return 0
        }
        res += items.count
        items.forEach {
            res += $0.numberOfAllItems()
        }
        return res
    }
    
    var numberOfAllItemsWithOutFold: Int {
        var res = 0
        guard let items = self.items else {
            return 0
        }
        guard let fold = self.fold else {
            return 1
        }
        if !fold {
            res += items.count
        }
        items.forEach {
            res += $0.numberOfAllItemsWithOutFold
        }
        return res
    }
    
    func transform2JsonParserNode1D() -> [JsonParserNode1D] {
        var res = [JsonParserNode1D]()
        if let items = self.items {
            items.forEach({
                if $0.stringValue == nil {
                    let node1d = JsonParserNode1D.init(id: $0.id)
                    node1d.key = $0.key
                    node1d.fold = true
                    node1d.hierarchy = $0.hierarchy
                    node1d.parentId = $0.parent?.id
                    res.append(node1d)
                }
                res.append(contentsOf: $0.transform2JsonParserNode1D())
            })
        }else{
            let node1d = JsonParserNode1D.init(id: self.id)
            node1d.key = self.key
            node1d.stringValue = self.stringValue
            node1d.hierarchy = self.hierarchy
            node1d.fold = nil
            node1d.parentId = self.parent?.id
            res.append(node1d)
        }
        
        return res
    }
    
    deinit {
        print("\(self) deinit")
    }
}

class JsonParserNode1D {
    var key = ""
    var stringValue: String?
    var fold: Bool?
    var hierarchy: Int = 0
    let id: String
    var parentId: String?
    weak var parent: JsonParserNode1D?
    
    init(id: String) {
        self.id = id
    }
    
    deinit {
        print("\(self) deinit")
    }
    
    func findParent(in collection: [JsonParserNode1D]) {
        self.parent = collection.filter({ $0.id == self.parentId }).first
    }
    
    var isParentFold: Bool {
        var parent = self.parent
        var all: [Bool] = []
        while let p = parent {
            all.append(p.fold ?? false)
            parent = p.parent
        }
        return all.contains(true)
    }
}
