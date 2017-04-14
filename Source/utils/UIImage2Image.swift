//
//  UIImage2Image.swift
//  Pods
//
//  Created by Victor Sukochev on 14/04/2017.
//
//

import UIKit

var imagesMap = [String: UIImage]()
public extension UIImage {
    public var image: Image {
        get {
            var oldId: String?
            for key in imagesMap.keys {
                if self == imagesMap[key] {
                    oldId = key
                }
            }
            
            let id = oldId ?? UUID().uuidString
            imagesMap[id] = self
            
            return Image(src: "memory://\(id)")
        }
    }
}
