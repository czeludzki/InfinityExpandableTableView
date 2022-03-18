#  InfinityExpandableTableView

![](SimulatorScreenRecording.gif)

一开始我只是想显示一些比较复杂的, 不规则的 json 数据, 以树的形式展示在 UITableView 上, 但是没有找到比较适合我的轮子, 于是就自己写了一个.

从 JsonParserNode.swift 中，你可以找到 JsonParserNode3D、JsonParserNode2D、JsonParserNode1D，它们被用来以降维方式解析json数据。

This looks like:
`Dictionary<String, Any> -> JsonParserNode3D -> JsonParserNode2D -> [JsonParserNode1D]`  

JsonParserNode3D 是一种多维节点模型, 其 value 指向 `Array<JsonParserNode3D>`, `Dictionary<String ,JsonParserNode3D>`, `String` 这几种类型数据.  
JsonParserNode2D 是一种多叉树节点模型, 其 items 指向 `Array<JsonParserNode2D>`.  
JsonParserNode1D 是用于对一行数据展示的模型.
使用时需要逐级解析, 从 3D 到 2D 到 1D.  

模型 JsonParserNode.swift 大概是可靠的, 可复用于任何项目的, 但提供思路是我的本意, 用于生产前请注意测试.  
而关于 UITableView 的无限折叠或扩展的实现, 你也可以在 TableViewController.swift 找到实现的方式, 其实只要模型设计好, 实现效果并不复杂.  

Enjoy!
