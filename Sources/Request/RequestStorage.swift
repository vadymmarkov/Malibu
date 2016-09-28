import Foundation

final class RequestStorage {

  let key: String
  private(set) var requests = [String: NSURLRequest]()

  private var userDefaults: NSUserDefaults {
    return NSUserDefaults.standardUserDefaults()
  }

  // MARK: - Initialization

  init(name: String) {
    key = "no.hyper.Malibu.RequestStorage.\(name)"
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

  // MARK: - Load

  func load() -> [String: NSURLRequest] {
    guard let data = userDefaults.objectForKey(key) as? NSData,
      dictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: NSURLRequest]
      else { return [:] }

    return dictionary
  }
}
