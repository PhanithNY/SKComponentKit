//
//  Optional+Extensions.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
extension Optional where Wrapped == String {
  var orEmpty: String { self ?? "" }
}
#endif
