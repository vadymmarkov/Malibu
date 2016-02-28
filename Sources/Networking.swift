import Foundation

public class Networking {
  
  enum SessionTaskKind {
    case Data, Upload, Download
  }
  
  let sessionConfiguration: SessionConfiguration
  
  lazy var session: NSURLSession = {
    return NSURLSession(configuration: self.sessionConfiguration.configuration)
  }()
  
  public init(sessionConfiguration: SessionConfiguration = .Default) {
    self.sessionConfiguration = sessionConfiguration
  }
}
