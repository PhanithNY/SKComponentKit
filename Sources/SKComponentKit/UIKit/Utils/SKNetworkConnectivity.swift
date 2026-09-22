//
//  SKNetworkConnectivity.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import Network
import UIKit

@MainActor
public final class SKNetworkConnectivity {
  public static let current = SKNetworkConnectivity()

  /// The latest system network-path status. This is false before the first path update;
  /// a satisfied path does not guarantee that a specific server is reachable.
  public var isConnectedToInternet: Bool {
    monitor?.currentPath.status == .some(.satisfied)
  }

  private var monitor: NWPathMonitor?
  private init() {}

  /// Start monitoring once. Subsequent calls leave the active monitor running.
  public func startMonitor() {
    if monitor == nil {
      monitor = NWPathMonitor()
      let queue = DispatchQueue.global(qos: .userInteractive)
      monitor?.start(queue: queue)
    }
  }

  /// Stop monitoring and clear the last status. Call startMonitor() to resume.
  public func stopMonitor() {
    monitor?.cancel()
    monitor = nil
  }
}
#endif
