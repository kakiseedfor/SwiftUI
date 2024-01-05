//
//  ScenesToAlignmentGuide.swift
//  SwiftProject
//
//  Created by kaki Yen on 2022/1/7.
//

import SwiftUI

extension VerticalAlignment {
    struct V_AlignCenter: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }
    
    static let v_alignCenter = VerticalAlignment(V_AlignCenter.self)
}

extension HorizontalAlignment {
    struct H_AlignCenter: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }
    
    static let h_alignCenter = HorizontalAlignment(H_AlignCenter.self)
}

extension Alignment {
    static let alignCenter = Alignment(horizontal: HorizontalAlignment.h_alignCenter, vertical: VerticalAlignment.v_alignCenter)
}
