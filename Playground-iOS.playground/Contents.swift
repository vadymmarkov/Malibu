// Malibu iOS Playground

import PlaygroundSupport
import Malibu

// Declare custom types.

enum ParseError: Error {
  case InvalidJson
}

struct User: CustomStringConvertible {
  let id: Int
  let name: String
  let username: String
  let email: String

  var description: String {
    return "Id: \(id)\nName: \(name)\nUsername:\(username)\nEmail: \(email)\n"
  }

  init(dictionary: [String: Any]) throws {
    guard
      let id = dictionary["id"] as? Int,
      let name = dictionary["name"] as? String,
      let username = dictionary["username"] as? String,
      let email = dictionary["email"] as? String
      else {
        throw ParseError.InvalidJson
    }

    self.id = id
    self.name = name
    self.username = username
    self.email = email
  }
}

// Service

enum PlaceholderService: Endpoint {
  case fetchUsers
  case createUser(id: Int, name: String, username: String, email: String)

  static let baseUrl: URLStringConvertible = "http://jsonplaceholder.typicode.com/"
  static let sessionConfiguration: SessionConfiguration = .default

  // Additional headers will be used in the each request.
  static var headers: [String : String] {
    return ["Accept" : "application/json"]
  }

  var request: Request {
    switch self {
    case .fetchUsers:
      return Request.get("users", etagPolicy: .disabled)
    case .createUser(let id, let name, let username, let email):
      return Request.post("users", parameters: [
        "id": id,
        "name": name,
        "username": username,
        "email": email])
    }
  }
}

// Create and configure Networking.
let networking = Networking<PlaceholderService>()

// Make GET request
networking.request(.fetchUsers)
  .validate()
  .toJsonArray()
  .then({ data -> [User] in
    return try data.map({ try User(dictionary: $0) })
  })
  .done({ users in
    print("A list of users:\n")
    users.forEach { print($0) }
  })
  .fail({ error in
    print(error)
  })
  .always({ _ in
    /// ...
  })

// Make POST request

networking.request(.createUser(id: 11,
                               name: "Malibu",
                               username: "malibu",
                               email: "malibu@example.org"))
  .validate()
  .toJsonDictionary()
  .then({ data -> User in
    return try User(dictionary: data)
  })
  .done({ user in
    print("New user has been successfully created:\n")
    print(user)
  })
  .fail({ error in
    print(error)
  })
  .always({ _ in
    /// ...
  })

PlaygroundPage.current.needsIndefiniteExecution = true
