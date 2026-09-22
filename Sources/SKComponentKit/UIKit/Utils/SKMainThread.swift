//
//  SKMainThread.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import Foundation

public enum SKMainThread {
  public static func run(_ block: @escaping @MainActor @Sendable () -> Void) {
    if Thread.isMainThread {
      MainActor.assumeIsolated { block() }
    } else {
      DispatchQueue.main.async { block() }
    }
  }

  public static func delay(
    after deadline: DispatchTime,
    execute work: @escaping @MainActor @Sendable () -> Void
  ) {
    DispatchQueue.main.asyncAfter(deadline: deadline) { work() }
  }
}
#endif
