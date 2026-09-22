//
//  String+Extensions.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

#if canImport(UIKit)
import UIKit

extension String {
  var isNotEmpty: Bool {
    !isEmpty
  }

  var doubleValue: Double {
    let value = replacingOccurrences(of: ",", with: ".")
    return Double(value) ?? 0.0
  }

  var isPhoneNumber: Bool {
    do {
      let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
      let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
      if let res = matches.first {
        return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count && (self.count >= 9 && self.count <= 10) && self.first == "0" && !self.hasPrefix("00")
      } else {
        return false
      }
    } catch {
      return false
    }
  }

  var formattedPhoneNumber: String {
    applyPatternOnNumbers(pattern: "### ### ####", replacmentCharacter: "#")
  }

  func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
    var pureNumber = self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    for index in 0 ..< pattern.count {
      guard index < pureNumber.count else { return pureNumber }
      let stringIndex = String.Index(utf16Offset: index, in: self)//String.Index(encodedOffset: index)
      let patternCharacter = pattern[stringIndex]
      guard patternCharacter != replacmentCharacter else { continue }
      pureNumber.insert(patternCharacter, at: stringIndex)
    }
    return pureNumber
  }

  func replaceCommaWithDot(using string: String, in range: NSRange) -> Bool {
    let oldText = replacingOccurrences(of: ",", with: ".")
    if let r = Range(range, in: oldText) {
      let newString = string.replacingOccurrences(of: ",", with: ".")
      let newText = oldText.replacingCharacters(in: r, with: newString)
      let isNumeric = newText.isEmpty || (Double(newText) != nil)
      let numberOfDots = newText.components(separatedBy: ".").count - 1

      let numberOfDecimalDigits: Int
      if let dotIndex = newText.firstIndex(of: ".") {
        numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
      } else {
        numberOfDecimalDigits = 0
      }

      return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
    } else {
      return true
    }
  }

  func limitComma(using string: String, in range: NSRange) -> Bool {
    let oldText = replacingOccurrences(of: ",", with: ".")
    if let r = Range(range, in: oldText) {
      let newString = string.replacingOccurrences(of: ",", with: ".")
      let newText = oldText.replacingCharacters(in: r, with: newString)
      let numberOfDots = newText.components(separatedBy: ".").count - 1

      let numberOfDecimalDigits: Int
      if let dotIndex = newText.firstIndex(of: ".") {
        numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
      } else {
        numberOfDecimalDigits = 0
      }

      return numberOfDots <= 1 && numberOfDecimalDigits <= 2
    } else {
      return true
    }
  }

  func toUniversalNumber() -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "km-KH")
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = false

    var str: String = self
    let universalNumerals = (0...9).map { String($0) }
    let khmerNumerals = ["០", "១", "២", "៣", "៤", "៥", "៦", "៧", "៨", "៩"]
    let zipped = zip(universalNumerals, khmerNumerals)
    let range = NSRange(location: 0, length: (str as NSString).length)

    zipped.forEach { universal, khmer in
      do {
        let regex = try NSRegularExpression(pattern: khmer, options: .caseInsensitive)
        str = regex.stringByReplacingMatches(in: str, options: .reportCompletion, range: range, withTemplate: universal)
      } catch {
        print(error)
      }
    }
    return str
  }
}

extension String {
  var isNumeric: Bool {
    let allowedCharacters = NSCharacterSet(charactersIn:"$៛0123456789.,").inverted
    let compSepByCharInSet = self.components(separatedBy: allowedCharacters)
    let numberFiltered = compSepByCharInSet.joined(separator: "")
    let allowed: Bool = self == numberFiltered
    return allowed
  }

  func transformToInternationalNumber() -> String {
    let keypairs = ["០": "0", "១": "1", "២": "2", "៣": "3", "៤": "4", "៥": "5", "៦": "6", "៧": "7", "៨": "8", "៩": "9"]
    var content = self
    keypairs.forEach { content = content.replacingOccurrences(of: $0, with: $1) }
    return content
  }
}
#endif
