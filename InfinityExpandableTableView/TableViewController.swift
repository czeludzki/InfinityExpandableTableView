//
//  ViewController.swift
//  InfinityExpandableTableView
//
//  Created by siu on 2022/3/18.
//

import UIKit

class TableViewController: UITableViewController {

    var jsonParserNode3D: JsonParserNode3D<Dictionary<String, Any>>?
    
    var jsonParserNode2D: JsonParserNode2D?
    
    var jsonParserNode1D: [JsonParserNode1D]?
    
    var dataSource: [JsonParserNode1D]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let jsonData = try? Data.init(contentsOf: Bundle.main.url(forResource: "JSON", withExtension: "json")!) else { return }
        guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? Dictionary<String, Any> else { return }
        
        self.jsonParserNode3D = JsonParserNode3D.init(with: "/root", value: json, hierarchy: 0)
        self.jsonParserNode2D = self.jsonParserNode3D?.transform2JsonParserNode2D(key: "/")
        self.jsonParserNode1D = self.jsonParserNode2D?.transform2JsonParserNode1D()
        
        self.jsonParserNode1D?.forEach({
            // 为 self.jsonParserNode1D 中的所有对象找到 parent
            $0.findParent(in: self.jsonParserNode1D ?? [])
            // 展开 self.jsonParserNode1D 中第一层根
            if $0.hierarchy == 1 && $0.fold != nil {
                $0.fold = false
            }
        })
        
        self.dataSource = self.generateDataSource()
        
        self.tableView.reloadData()
    }

    func generateDataSource() -> [JsonParserNode1D] {
        var res: [JsonParserNode1D] = []
        
        self.jsonParserNode1D?.forEach({
            guard let _ = $0.parent else {
                // 根没有 parent, 所以一定要加上
                res.append($0)
                return
            }
            if !$0.isParentFold {
                res.append($0)
            }
        })
        
        return res
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = self.dataSource?.count {
            return num
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        if let node1d = self.dataSource?[indexPath.row] {
            cell.node1d = node1d
        }else{
            cell.keyLabel.text = "something wrong"
            cell.valueLabel.text = "shit happens..."
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let node1d = self.dataSource?[indexPath.row], let _ = node1d.fold else { return }
        node1d.fold?.toggle()
        self.dataSource = self.generateDataSource()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let node1d = self.dataSource?[indexPath.row], let _ = node1d.fold else { return nil }
        return indexPath
    }

}

