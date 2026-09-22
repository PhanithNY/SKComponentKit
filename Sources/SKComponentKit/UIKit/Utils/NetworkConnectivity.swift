#if canImport(UIKit)
//
//  NetworkConnectivity.swift
//
//
//  Created by Suykorng on 16/4/24.
//

import Network
import UIKit

@available(iOS 12.0, *)
@MainActor
final class NetworkConnectivity {
  static let current = NetworkConnectivity()

  var isConnectedToInternet: Bool {
    monitor?.currentPath.status == .some(.satisfied)
  }

  private var monitor: NWPathMonitor?
  private init() {}

  final func startMonitor() {
    if monitor == nil {
      monitor = NWPathMonitor()
      let queue = DispatchQueue.global(qos: .userInteractive)
      monitor?.start(queue: queue)
    }
  }
}
#endif
