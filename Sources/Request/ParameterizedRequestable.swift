public protocol ParameterizedRequestable: Requestable {
  init()
  init(parameters: [String : AnyObject], headers: [String : String])
}

extension ParameterizedRequestable {

  public init(parameters: [String : AnyObject] = [:], headers: [String : String] = [:]) {
    self.init()

    parameters.forEach { key, value in
      self.message.parameters[key] = value
    }

    headers.forEach { key, value in
      self.message.headers[key] = value
    }
  }
}
