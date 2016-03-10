import UIKit
import Foundation

protocol ETagStoring {
  func add(value: String, forKey key: String)
  func get(key: String) -> String?
  func clear()
}

class ETagStorage: ETagStoring {

  static private(set) var path = Utils.filePath("ETags.dictionary")

  private var dictionary = [String: String]()

  private let fileManager: NSFileManager = {
    let manager = NSFileManager.defaultManager()
    return manager
  }()

  // MARK: - Initialization

  init() {
    reload()
  }

  // MARK: - Public Methods

  func add(value: String, forKey key: String) {
    dictionary[key] = value
    save()
  }

  func get(key: String) -> String? {
    return dictionary[key]
  }

  func clear() {
    dictionary = [:]
    save()
  }

  // MARK: - Helpers

  func save() {
    let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(dictionary)

    do {
      try data.writeToFile(ETagStorage.path, options: .DataWritingAtomic)
    } catch {
      NSLog("Malibu: Error in saving of \(ETagStorage.path) to the local storage")
    }
  }

  func reload() {
    dictionary = [:]

    guard fileManager.fileExistsAtPath(ETagStorage.path) else { return }

    guard let data = NSKeyedUnarchiver.unarchiveObjectWithFile(ETagStorage.path)
      as? [String : String] else { return }

    dictionary = data
  }
}
