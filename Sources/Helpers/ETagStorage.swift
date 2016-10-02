import Foundation

protocol ETagStoring {
  func add(_ value: String, forKey key: String)
  func get(_ key: String) -> String?
  func clear()
}

class ETagStorage: ETagStoring {

  static fileprivate(set) var path = Utils.filePath("ETags.dictionary")

  fileprivate var dictionary = [String: String]()

  fileprivate let fileManager: FileManager = {
    let manager = FileManager.default
    return manager
  }()

  // MARK: - Initialization

  init() {
    reload()
  }

  // MARK: - Public Methods

  func add(_ value: String, forKey key: String) {
    dictionary[key] = value
    save()
  }

  func get(_ key: String) -> String? {
    return dictionary[key]
  }

  func clear() {
    dictionary = [:]
    save()
  }

  // MARK: - Helpers

  func save() {
    let data: Data = NSKeyedArchiver.archivedData(withRootObject: dictionary)

    do {
      try data.write(to: URL(fileURLWithPath: ETagStorage.path), options: .atomic)
    } catch {
      NSLog("Malibu: Error in saving of \(ETagStorage.path) to the local storage")
    }
  }

  func reload() {
    dictionary = [:]

    guard fileManager.fileExists(atPath: ETagStorage.path) else { return }

    guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: ETagStorage.path)
      as? [String : String] else { return }

    dictionary = data
  }
}
