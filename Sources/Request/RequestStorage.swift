import Foundation

final class RequestStorage {

  static let domain = "no.hyper.Malibu.RequestStorage"

  var key: String

  var requests = [String: RequestCapsule]()

  private var userDefaults: NSUserDefaults {
    return NSUserDefaults.standardUserDefaults()
  }

  // MARK: - Initialization

  init(name: String = "Default") {
    key = "\(RequestStorage.domain).\(name)"
    requests = load()
  }

  // MARK: - Save

  func save(capsule: RequestCapsule) {
    requests[capsule.id] = capsule
    saveAll()
  }

  func saveAll() {
    let data = NSKeyedArchiver.archivedDataWithRootObject(requests)
    userDefaults.setObject(data, forKey: key)
    userDefaults.synchronize()
  }

  // MARK: - Remove

  func remove(capsule: RequestCapsule) {
    requests.removeValueForKey(capsule.id)
    saveAll()
  }

  func clear() {
    requests.removeAll()
    userDefaults.removeObjectForKey(key)
    userDefaults.synchronize()
  }

  static func clearAll() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let keys = userDefaults.dictionaryRepresentation().keys
    let storageKeys = keys.filter { $0.containsString(domain) }

    for key in storageKeys {
      userDefaults.removeObjectForKey(key)
    }
  }

  // MARK: - Load

  func load() -> [String: RequestCapsule] {
    guard let data = userDefaults.objectForKey(key) as? NSData,
      dictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: RequestCapsule]
      else { return [:] }

    return dictionary
  }
}
