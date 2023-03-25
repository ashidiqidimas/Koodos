//
//  UIImage+isEqualToImage.swift
//  Koodos
//
//  Created by Dimas on 24/03/23.
//

import UIKit

extension UIImage {

    func isEqualToImage(_ image: UIImage) -> Bool {
        return self.pngData() == image.pngData()
    }

}
