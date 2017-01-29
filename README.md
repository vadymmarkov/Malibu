![Malibu logo](https://raw.githubusercontent.com/hyperoslo/Malibu/master/Images/cover.png)

[![CI Status](http://img.shields.io/travis/hyperoslo/Malibu.svg?style=flat)](https://travis-ci.org/hyperoslo/Malibu)
[![Version](https://img.shields.io/cocoapods/v/Malibu.svg?style=flat)](http://cocoadocs.org/docsets/Malibu)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Malibu.svg?style=flat)](http://cocoadocs.org/docsets/Malibu)
[![Platform](https://img.shields.io/cocoapods/p/Malibu.svg?style=flat)](http://cocoadocs.org/docsets/Malibu)
![Swift](https://img.shields.io/badge/%20in-swift%203.0-orange.svg)

## Description

Palm trees, coral reefs and breaking waves. Welcome to the surf club **Malibu**,
a networking library built on ***promises***. It's more than just a wrapper
around `URLSession`, but a powerful framework that helps to chain your
requests, validations and request processing.

Using [When](https://github.com/vadymmarkov/When) under the hood, **Malibu**
adds a lot of sugar helpers and moves your code up to the next level:

* No more "callback hell".
* Your requests are described in one place.
* Response processing could be easily broken down into multiple logical tasks.
* Data and errors are handled separately.
* Your networking code is much cleaner, readable and follows `DRY` principle.

Equip yourself with the necessary gears of **Malibu**, become a big wave surfer
and let the days of shark infested asynchronous networking be a thing of the
past. Enjoy the ride!

## Features

- [x] Multiple network stacks
- [x] Declarative requests
- [x] Chainable response callbacks built on ***promises***
- [x] All needed content types and parameter encodings
- [x] HTTP response validation
- [x] Response data serialization
- [x] Response mocking
- [x] Request, response and error logging
- [x] `ETag` support
- [x] Synchronous and asynchronous modes
- [x] Request pre-processing and middleware
- [x] Request offline storage
- [x] Extensive unit test coverage

## Table of Contents

* [Catching the wave](#catching-the-wave)
* [Endpoint](#endpoint)
  * [Session configuration](#session-configuration)
  * [Mocks](#mocks)
* [Request](#request)
  * [Content types](#content-types)
  * [Encoding](#encoding)
  * [ETags](#etags)
* [Networking](#networking)
  * [Initialization](#initialization)
  * [Mode](#mode)
  * [Pre-processing](#pre-processing)
  * [Middleware](#middleware)
  * [Authentication](#authentication)
  * [Making a request](#making-a-request)
  * [Wave and Ride](#wave-and-ride)
  * [Offline storage](#offline-storage)
* [Response](#response)
  * [Serialization](#serialization)
  * [Validation](#validation)
* [Core](#core)
  * [Multiple networkings](#multiple-networkings)
  * [Backfoot surfer](#backfoot-surfer)
* [Logging](#logging)
* [Installation](#installation)
* [Author](#author)
* [Credits](#credits)
* [Contributing](#contributing)
* [License](#license)

## Catching the wave

You can start your ride straight away, not thinking about configurations:

```swift
// Create your request
let request = Request.get(
  "http://sharkywaters.com/api/boards",
  parameters: ["type": 1]
)

// Make a call
Malibu.GET(request)
  .validate()
  .toJsonDictionary()
  .then({ dictionary -> [Board] in
    // Let's say we use https://github.com/zenangst/Tailor for mapping
    return try dictionary.relationsOrThrow("boards") as [Board]
  })
  .done({ boards in
    // Handle response data
  })
  .fail({ error in
    // Handle errors
  })
  .always({ _ in
    // Hide progress bar
  })
```

If you still don't see any benefits, keep scrolling down and be ready for even
more magic 😉...

## Endpoint

Most of the time we need separate network stacks to work with multiple API
services. It's super easy to archive with **Malibu**. First, create an
`enum` that conforms to **Endpoint** protocol and describe your requests with
all the properties:

```swift
enum SharkywatersService: Endpoint {
  // Describe requests
  case fetchBoards
  case showBoard(id: Int)
  case createBoard(type: Int, title: String)
  case updateBoard(id: Int, type: Int, title: String)
  case deleteBoard(id: Int)

  // Every request will be scoped by the base url
  static var baseUrl: URLStringConvertible = "http://sharkywaters.com/api/"
  // Additional headers for every request
  static var headers: [String: String] = [
    "Accept" : "application/json"
  ]

  // Build requests
  var request: Request {
    switch self {
    case .fetchBoards:
      return Request.get("boards")
    case .showBoard(let id):
      // Let's use JSON dictionary as a mock data
      return Request.get("boards:\(id)", mock: Mock(json: ["type": 1, "title": "Classic"]))
    case .createBoard(let type, let title):
      return Request.post("boards", parameters: ["type": type, "title": title])
    case .updateBoard(let id, let title):
      return Request.patch("boards\(id)", parameters: ["title": title])
    case .deleteBoard(let id):
      return Request.delete("boards\(id)")
    }
  }
}
```

### Additional headers

Additional headers will be used in the each request made on the networking:

```swift
networking.additionalHeaders = {
  ["Accept" : "application/json"]
}
```

**Note** that `Accept-Language`, `Accept-Encoding` and `User-Agent` headers are
included automatically.

### Mocks

Mocking is great when it comes to writing your tests. But it also could speed
up your development while the backend developers are working really hardly
on API implementation.

In order to start mocking you have to do the following:

**Change the `mode`**

A mode for real HTTP request only:

```swift
let networking = Networking<SharkywatersService>(mockBehavior: .never)
```

A mode for mocks only:
```swift
let networking = Networking<SharkywatersService>(mockBehavior: .always)
```

Both real and fake requests can be used in a mix:
```swift
let networking = Networking<SharkywatersService>(mockBehavior: .partial)
```

**Create a mock**

With response data from file:

```swift
let request = Request.get(
  "boards",
  mock: Mock(fileName: "boards.json")
)
```

With response from JSON dictionary:

```swift
let request = Request.get(
  "boards",
  mock: Mock(json: ["data": ["id": 1, "title": "Balsa Fish"]])
)
```

NSData mock:

```swift
let request = Request.get(
  "boards:\(id)",
  mock: Mock(
    // Needed response
    response: mockedResponse,
    // Response data
    data: responseData,
    // Custom error, `nil` by default
    error: customError
  )
)
```

## Request

Request is described with a struct in **Malibu**:

```swift
let request = Request(
  // HTTP method
  method: .get,
  // Request url or path
  resource: "boards",
  // Content type
  contentType: .query,
  // Parameters
  parameters: ["type": 1, "text": "classic"],
  // Headers
  headers: ["custom": "header"],
  // Optional mock (file, dictionary, data)
  mock: Mock(fileName: "boards.json"),
  // Enables or disables automatic ETags handling
  etagPolicy: .disabled,
  // Offline storage configuration
  storePolicy: .unspecified,
  // Cache policy
  cachePolicy: .useProtocolCachePolicy)
```

There are also 6 helper methods with default values for every HTTP method:

```swift
// GET request
let getRequest = Request.get("boards")

// POST request
let postRequest = Request.post(
  "boards",
  // Content type is set to `.json` by default for POST
  contentType: .formURLEncoded,
  parameters: ["type" : kind, "title" : title])

// PUT request
let postRequest = Request.put("boards/1", parameters: ["type" : kind, "title" : title])

// PATCH request
let postRequest = Request.patch("boards/1", parameters: ["title" : title])

// DELETE request
let deleteRequest = Request.delete("boards/1")
```

### Content types

* `query` - creates a query string to be appended to any existing url.
* `formURLEncoded` - uses `application/x-www-form-urlencoded` as a
`Content-Type` and formats your parameters with percent-encoding.
* `json` - sets the `Content-Type` to `application/json` and sends a JSON
representation of the parameters as the body of the request.
* `multipartFormData` - sends parameters encoded as `multipart/form-data`.
* `custom(String)` - uses given `Content-Type` string as a header.

### Encoding

**Malibu** comes with 3 parameter encoding implementations:
* `FormURLEncoder` - a percent-escaped encoding following RFC 3986.
* `JsonEncoder` - `JSONSerialization` based encoding.
* `MultipartFormEncoder` - multipart data builder.

You can extend default functionality by adding a custom parameter encoder
that conforms to `ParameterEncoding` protocol:

```swift
// Override default JSON encoder
Malibu.parameterEncoders[.json] = CustomJsonEncoder()

// Register encoder for the custom encoding type
Malibu.parameterEncoders[.custom("application/xml")] = CustomXMLEncoder()
```

### ETags

**Malibu** cares about [HTTP ETags](https://en.wikipedia.org/wiki/HTTP_ETag).
When the web server returns an HTTP response header `ETag`, it will be
cached locally and set as `If-None-Match` request header next time you perform
the same request. Automatic ETags handling is enabled by default for `GET`,
`PUT` and `PATCH` requests, but it could easily be changed for the each request
specifically.

```swift
let getRequest = Request.get("boards". etagPolicy: .disabled)
```

## Networking

`Networking` class is a core component of **Malibu** that pre-process and
executes actual HTTP requests on a specified API service.

### Initialization

It's pretty straightforward to create a new `Networking` instance:

```swift
// Simple networking that works with `SharkywatersService` requests.
let simpleNetworking = Networking<SharkywatersService>()

// More advanced networking
let networking = Networking(
  // `OperationQueue` Mode
  mode: .async,
  // Mock behavior (never, partial, always)
  mockBehavior: .never,
  // `default`, `ephemeral`, `background` or `custom`
  sessionConfiguration: .default,
  // Custom `URLSessionDelegate` could set if needed
  sessionDelegate: self
)
```

### Session configuration

`SessionConfiguration` is a wrapper around `URLSessionConfiguration` and could
represent 3 standard session types + 1 custom type:
* `default` - configuration that uses the global singleton credential, cache and
cookie storage objects.
* `ephemeral` - configuration with no persistent disk storage for cookies, cache
or credentials.
* `background` - session configuration that can be used to perform networking
operations on behalf of a suspended application, within certain constraints.
* `custom(URLSessionConfiguration)` - if you're not satisfied with standard
types, your custom `URLSessionConfiguration` goes here.

### Mode

**Malibu** uses `OperationQueue` to execute/cancel requests. It makes it
easier to manage request lifetime and concurrency.

When you create a new networking instance there is an optional argument to
specify **mode** which will be used:

- `sync`
- `async`
- `limited(maxConcurrentOperationCount)`

### Pre-processing

```swift
// Use this closure to modify your `Requestable` value before `URLRequest`
// is created on base of it
networking.beforeEach = { request in
  var request = request
  request.message.parameters["userId"] = "12345"

  return request
}

// Use this closure to modify generated `URLRequest` object
// before the request is made
networking.preProcessRequest = { (request: URLRequest) in
  var request = request
  request.addValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9", forHTTPHeaderField: "token")
  return request
}
```

### Middleware

**Middleware** is the function which works as the first promise in the chain,
before the actual request. It could be used to prepare networking, do some
kind of pre-processing task, cancel request under particular conditions, etc.

For example, in the combination with https://github.com/hyperoslo/OhMyAuth

```swift
// Set middleware in your configuration
// Remember to `resolve` or `reject` the promise
networking.middleware = { promise in
  AuthContainer.serviceNamed("service")?.accessToken { accessToken, error in
    if let error == error {
      promise.reject(error)
      return
    }

    guard let accessToken = accessToken else {
      promise.reject(CustomError())
      return
    }

    self.networking.authenticate(bearerToken: accessToken)
    promise.resolve()
  }
}

// Send your request like you usually do.
// Valid access token will be set to headers before the each request.
networking.GET(request)
  .validate()
  .toJsonDictionary()
```

### Authentication

```swift
// HTTP basic authentication with username and password
networking.authenticate(username: "malibu", password: "surfingparadise")

// OAuth 2.0 authentication with Bearer token
networking.authenticate(bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9")

// Custom authorization header
networking.authenticate(authorizationHeader: "Malibu-Header")
```

### Making a request

`Networking` is set up and ready, so it's time to fire some requests. Make
a request by calling `request` functions with the corresponding endpoint as an
argument.

```swift
let networking = Networking<SharkywatersService>()

networking.request(.fetchBoards)
  .validate()
  .toJsonDictionary()
  .done({ data in
    print(data)
  })

networking.request(.createBoard(kind: 2, title: "Balsa Fish"))
  .validate()
  .toJsonDictionary()
  .done({ data in
    print(data)
  })

networking.request(.deleteBoard(id: 11))
  .fail({ error in
    print(error)
  })
```

### Wave and Ride

`Wave` object consists of `Data`, `URLRequest` and `HTTPURLResponse`
properties.

`Ride` is returned by every request method. It extends `Promise<Wave>` by
adding `URLSessionTask` that you might want to cancel when it's needed. You
may use `Ride` object to add different callbacks and build chains of tasks. It
has a range of useful helpers, such as validations and serialization.

```swift
let ride = networking.request(.fetchBoards)

// Cancel the task
ride.cancel()

// Create chains and add callbacks on promise object
ride
  .validate()
  .toString()
  .then({ string in
    // ...
  })
  .done({ _ in
    // ...
  })
```

### Offline storage

Want to **store request** when there is no network connection?

```swift
struct BoardDeleteRequest: DELETERequestable {
  var message: Message
  var storePolicy: StorePolicy = .offline // Set store policy

  init(id: Int) {
    message = Message(resource: "boards:\(id)")
  }
}
```

Want to **replay** cached requests?

```swift
networking.replay().done({ result
  print(result)
})
```

Request storage is networking-specific, and while it replays cached requests
it will be set to `Sync` mode. Cached request will go through normal request
lifecycle, with applied middleware and pre-process operations. Request will be
automatically removed from the storage when it's completed.

## Response

### Serialization

**Malibu** gives you a bunch of methods to serialize response data:

```swift
let ride = networking.GET(BoardsRequest())

ride.toData() // -> Promise<Data>
ride.toString() // -> Promise<String>
ride.toJsonArray() // -> Promise<[[String: Any]]>
ride.toJsonDictionary() // -> Promise<[String: Any]>
```

### Validation

**Malibu** comes with 4 validation methods:

```swift
// Validates a status code to be within 200..<300
// Validates a response content type based on a request's "Accept" header
networking.request(.fetchBoards).validate()

// Validates a response content type
networking.request(.fetchBoards).validate(
  contentTypes: ["application/json; charset=utf-8"]
)

// Validates a status code
networking.request(.fetchBoards).validate(statusCodes: [200])

// Validates with custom validator conforming to `Validating` protocol
networking.request(.fetchBoards).validate(using: CustomValidator())
```

## Core


### Backfoot surfer

**Malibu** has a shared networking object with default configurations for the
case when you need just something simple to catch the wave. It's not necessary
to create a custom `Endpoint` type, just call the same `request` method right
on `Malibu`:

```swift
Malibu.request(Request.get("http://sharkywaters.com/api/boards")
```

## Logging

If you want to see some request, response and error info in the console, you
get this for free. Just choose one of the available log levels:

* `none` - logging is disabled, so your console is not littered with networking
stuff.
* `error` - prints only errors that occur during the request execution.
* `info` - prints incoming request method + url, response status code and errors.
* `verbose` - prints incoming request headers and parameters in addition to
everything printed in the `info` level.

Optionally you can set your own loggers and adjust the logging to your needs:

```swift
// Custom logger that conforms to `ErrorLogging` protocol
Malibu.logger.errorLogger = CustomErrorLogger.self

// Custom logger that conforms to `RequestLogging` protocol
Malibu.logger.requestLogger = RequestLogger.self

// Custom logger that conforms to `ResponseLogging` protocol
Malibu.logger.responseLogger = ResponseLogger.self
```

## Author

Hyper Interaktiv AS, ios@hyper.no

## Installation

**Malibu** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Malibu'
```

**Malibu** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "hyperoslo/Malibu"
```

**Malibu** can also be installed manually.
Just *Download* and *drop* ```/Sources``` folder in your project.  

## Author

Hyper Interaktiv AS, ios@hyper.no

## Credits

Credits go to [Alamofire](https://github.com/Alamofire/Alamofire) for
inspiration and to [When](https://github.com/vadymmarkov/When) for ***promises***.

## Contributing

We would love you to contribute to **Malibu**, check the [CONTRIBUTING](https://github.com/hyperoslo/Malibu/blob/master/CONTRIBUTING.md) file for more info.

## License

**Malibu** is available under the MIT license. See the [LICENSE](https://github.com/hyperoslo/Malibu/blob/master/LICENSE.md) file for more info.
