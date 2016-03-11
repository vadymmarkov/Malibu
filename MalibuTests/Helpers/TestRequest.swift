import Foundation
import Malibu

struct TestRequest: Requestable {
  var message = Message(resource: "http://hyper.no")
}
