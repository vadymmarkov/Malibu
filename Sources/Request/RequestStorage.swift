import Foundation

final class RequestStorage {

  static let domain = "no.hyper.Malibu.RequestStorage"

  var key: String

  private(set) var requests = [String: NSURLRequest]()

  private var userDefaults: NSUserDefaults {
    return NSUserDefaults.standardUserDefaults()
  }

  // MARK: - Initialization

  init(name: String = "Default") {
    key = "\(RequestStorage.domain).\(name)"
    requests = load()
  }

  // MARK: - Save

  func save(request: NSURLRequest) {
    guard let key = request.URL?.absoluteString else {
      return
    }

    requests[key] = request
    saveAll()
  }

  func saveAll() {
    let data = NSKeyedArchiver.archivedDataWithRootObject(requests)
    userDefaults.setObject(data, forKey: key)
    userDefaults.synchronize()
  }

  // MARK: - Remove

  func remove(request: NSURLRequest) {
    guard let key = request.URL?.absoluteString else {
      return
    }

    requests.removeValueForKey(key)
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

  func load() -> [String: NSURLRequest] {
    guard let data = userDefaults.objectForKey(key) as? NSData,
      dictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: NSURLRequest]
      else { return [:] }

    return dictionary
  }
}
