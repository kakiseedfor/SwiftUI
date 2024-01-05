//
//  ArrayExtension.swift
//  SwiftFramework
//
//  Created by kaki Yen on 2022/11/21.
//

import Foundation

public extension Array {
    func findElements<V: Equatable>(_ keyPath: KeyPath<Self.Element, V>, _ keyValue: V) -> [Self.Element] {
        self.compactMap {
            let tempValue: V = $0[keyPath: keyPath]
            if keyValue == tempValue {
                return $0
            }
            
            return nil
        }
    }
}
