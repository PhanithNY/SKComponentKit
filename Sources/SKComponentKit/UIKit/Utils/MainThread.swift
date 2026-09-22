#if canImport(UIKit)
// Originally created by Suykorng on 16/4/24 in PHComponents.
// Updated for Swift 6 main-actor and Sendable closure isolation.
import Foundation

public enum MainThread {
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
