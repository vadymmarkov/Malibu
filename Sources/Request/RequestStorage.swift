import Foundation

final class RequestStorage {
  static let domain = "no.hyper.Malibu.RequestStorage"

  let key: String
  var requests = [String: RequestCapsule]()

  fileprivate var userDefaults: UserDefaults {
    return UserDefaults.standard
  }

  // MARK: - Initialization

  init(name: String = "Default") {
    key = "\(RequestStorage.domain).\(name)"
    requests = load()
  }

  // MARK: - Save

  func save(_ capsule: RequestCapsule) {
    requests[capsule.id] = capsule
    saveAll()
  }

  func saveAll() {
    let data = NSKeyedArchiver.archivedData(withRootObject: requests)
    userDefaults.set(data, forKey: key)
    userDefaults.synchronize()
  }

  // MARK: - Remove

  func remove(_ capsule: RequestCapsule) {
    requests.removeValue(forKey: capsule.id)
    saveAll()
  }

  func clear() {
    requests.removeAll()
    userDefaults.removeObject(forKey: key)
    userDefaults.synchronize()
  }

  static func clearAll() {
    let userDefaults = UserDefaults.standard
    let keys = userDefaults.dictionaryRepresentation().keys
    let storageKeys = keys.filter { $0.contains(domain) }

    for key in storageKeys {
      userDefaults.removeObject(forKey: key)
    }
  }

  // MARK: - Load

  func load() -> [String: RequestCapsule] {
    guard let data = userDefaults.object(forKey: key) as? Data,
      let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: RequestCapsule]
      else { return [:] }

    return dictionary
  }
}
