//
//  ScenesToKVC.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import Foundation

extension Array {
    subscript<V>(_ keyPath: KeyPath<Self.Element, V>) -> [V] {
        self.compactMap {
            $0[keyPath: keyPath]
        }
    }
    
    func copy() -> [Self.Element] where Self.Element: NSCopying {
        self.map {
            $0.copy(with: nil) as! Self.Element
        }
    }
    
    //数组去重
    func unique() -> [Self.Element] where Self.Element: Hashable {
        var tempSet: Set<Self.Element> = [] //利用 Set 集合不重复插入的机制
        
        return self.filter {
            tempSet.insert($0).inserted
        }
    }
}
