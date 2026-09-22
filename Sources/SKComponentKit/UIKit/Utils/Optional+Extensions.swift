#if canImport(UIKit)
extension Optional where Wrapped == String {
  var orEmpty: String { self ?? "" }
}
#endif
