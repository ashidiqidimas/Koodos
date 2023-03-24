//
//  UIImage+assetName.swift
//  Koodos
//
//  Created by Dimas on 24/03/23.
//

import UIKit

extension UIImage {
    var assetName: String? {
        self.imageAsset?.value(forKey: "assetName") as? String
    }
}
