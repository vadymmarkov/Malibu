import Foundation
import When

struct NetworkTaskRunning {
  func run(URLRequest: NSURLRequest, promise: Promise<NetworkResult>)
}
