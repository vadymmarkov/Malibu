import Foundation

protocol EtagStoring {
  func add(value: String, forKey key: String)
  func get(_ key: String) -> String?
  func clear()
}

final class EtagStorage: EtagStoring {
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

  func add(value: String, forKey key: String) {
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
      try data.write(to: URL(fileURLWithPath: EtagStorage.path), options: .atomic)
    } catch {
      NSLog("Malibu: Error in saving of \(EtagStorage.path) to the local storage")
    }
  }

  func reload() {
    dictionary = [:]

    guard fileManager.fileExists(atPath: EtagStorage.path) else { return }

    guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: EtagStorage.path)
      as? [String: String] else { return }

    dictionary = data
  }
}
