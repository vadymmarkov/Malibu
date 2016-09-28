import Foundation

public final class RequestStorage {
  let key = "Offline.RequestStorage"

  public static let shared: RequestStorage = RequestStorage()

  public private(set) var requests = [String: NSURLRequest]()

  private var userDefaults: NSUserDefaults {
    return NSUserDefaults.standardUserDefaults()
  }

  // MARK: - Initialization

  init() {
    requests = load()
  }

  // MARK: - Save

  public func save(request: NSURLRequest) {
    guard let key = request.URL?.absoluteString else {
      return
    }

    requests[key] = request
    saveAll()
  }

  public func saveAll() {
    let data = NSKeyedArchiver.archivedDataWithRootObject(requests)
    userDefaults.setObject(data, forKey: key)
    userDefaults.synchronize()
  }

  // MARK: - Remove

  public func remove(request: NSURLRequest) {
    guard let key = request.URL?.absoluteString else {
      return
    }

    requests.removeValueForKey(key)
    saveAll()
  }

  public func clear() {
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
