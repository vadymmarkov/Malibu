// Malibu iOS Playground

import XCPlayground
import Malibu

// Declare custom types.

enum Error: ErrorType {
  case InvalidJSON
}

struct User: CustomStringConvertible {
  let id: Int
  let name: String
  let username: String
  let email: String

  var description: String {
    return "Id: \(id)\nName: \(name)\nUsername:\(username)\nEmail: \(email)\n"
  }

  init(dictionary: [String: AnyObject]) throws {
    guard let id = dictionary["id"] as? Int,
      name = dictionary["name"] as? String,
      username = dictionary["username"] as? String,
      email = dictionary["email"] as? String else {
        throw Error.InvalidJSON
    }

    self.id = id
    self.name = name
    self.username = username
    self.email = email
  }
}

// Create and configure Networking.

let networking = Networking(
  // Every request made on this networking will be scoped by the base URL.
  baseURLString: "http://jsonplaceholder.typicode.com/"
)

// Additional headers will be used in the each request made on the networking.
networking.additionalHeaders = {
  ["Accept" : "application/json"]
}

// Register networking
Malibu.register("placeholder", networking: networking)

// GET request
struct UsersRequest: GETRequestable {
  var etagPolicy: ETagPolicy = .Disabled
  var message = Message(resource: "users")
}

Malibu.networking("placeholder").GET(UsersRequest())
  .validate()
  .toJSONArray()
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

// POST request
struct CreateUserRequest: POSTRequestable {
  var message = Message(resource: "users")

  init(id: Int, name: String, username: String, email: String) {
    message.parameters = [
      "id": id,
      "name": name,
      "username": username,
      "email": email
    ]
  }
}

let request = CreateUserRequest(id: 11,
                                name: "Malibu",
                                username: "malibu",
                                email: "malibu@example.org")

Malibu.networking("placeholder").POST(request)
  .validate()
  .toJSONDictionary()
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

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
