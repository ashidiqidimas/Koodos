//
//  CGAffineTransform+scale.swift
//  Koodos
//
//  Created by Dimas on 21/03/23.
//

import Foundation

extension CGAffineTransform {
    var scale: CGFloat {
        sqrt(Double(self.a * self.a + self.c * self.c))
    }
}
