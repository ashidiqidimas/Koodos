//
//  RenderImage.swift
//  Koodos
//
//  Created by Dimas on 24/03/23.
//

import UIKit

struct RenderImage {
    static func renderImage(in view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
}
