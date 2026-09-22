//
//  TypeAlias.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import Foundation

public typealias SKCallbackType<T> = ((T) -> Void)
public typealias SKCallback = (() -> Void)
#endif
