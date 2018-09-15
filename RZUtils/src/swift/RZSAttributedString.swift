//
//  RZSAttributedString.swift
//  RZUtilsSwift
//
//  Created by Brice Rosenzweig on 12/08/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import Foundation

extension NSAttributedString {
    static public func convertObjcAttributesDict( attributes: [String:Any]?) -> [NSAttributedString.Key:Any]? {
        var rv : [NSAttributedString.Key:Any]?
        
        if let attributes = attributes {
            rv = Dictionary(uniqueKeysWithValues:
                attributes.lazy.map { (NSAttributedString.Key($0.key), $0.value) }
            )
        }
        return rv
    }
}
