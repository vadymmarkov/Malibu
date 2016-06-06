# Malibu

[![CI Status](http://img.shields.io/travis/hyperoslo/Malibu.svg?style=flat)](https://travis-ci.org/hyperoslo/Malibu)
[![Version](https://img.shields.io/cocoapods/v/Malibu.svg?style=flat)](http://cocoadocs.org/docsets/Malibu)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Malibu.svg?style=flat)](http://cocoadocs.org/docsets/Malibu)
[![Platform](https://img.shields.io/cocoapods/p/Malibu.svg?style=flat)](http://cocoadocs.org/docsets/Malibu)
![Swift](https://img.shields.io/badge/%20in-swift%202.2-orange.svg)

## Description

Palm trees, ocean reefs and breaking waves. Welcome to the surf club **Malibu**,
a networking library built on ***promises***. It's more than just a
wrapper around `NSURLSession`, but a powerful framework that helps to chain your
requests, validations, parsing and handling. Using [When](https://github.com/vadymmarkov/When)
under the hood, it solves the problem of "callback hell", adds a lot of sugar
helpers and moves your code up to the next level. Describe requests in one
place, split your response processing into multiple logical tasks, process data
and errors separately and don't repeat yourself.

Enjoy the ride, equipped with all necessary gears by `Malibu`, and feel yourself
like a big wave surfer in sharky waters of asynchronous networking. Swell is
irregular and there's no guarantee that you'll get any, but we ***promise***.

## Table of Contents

* [Catching the wave](#catching-the-wave)
* [Request](#request)
  * [Content types](#content-types)
  * [Encoding](#encoding)
* [Networking](#networking)
  * [Making a request](#making-a-request)
  * [Session configuration](#session-configuration)
  * [Initialization](#initialization)
  * [Session configuration](#session-configuration)
  * [Additional headers](#additional-headers)
* [Response](#response)
  * [Serialization](#serialization)
  * [Validation](#validation)
* [Mocks](#mocks)
* [Logging](#logging)
* [Core](#core)
* [Installation](#installation)
* [Author](#author)
* [Credits](#credits)
* [Contributing](#contributing)
* [License](#license)

## Catching the wave

You can start your ride straight away, not thinking about configurations:

```swift
// Define your request
struct BoardsRequest: GETRequestable {
  var message = Message(resource: "https://surfwonderland.com/api/boards")

  init(kind: Int, text: String) {
    message.parameters = [
      "type": kind,
      "text": text
    ]
  }
}

// Make a call
let request = BoardsRequest(kind: 1, text: "classic")

Malibu.GET(request)
  .validate()
  .toJSONDictionary()
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

## Request

You can love it or you can hate it, but either way you have to create a `struct`
or a `class` representing your request. This decision has been made to separate
concerns into well-defined layers, so request with all it's properties is
described in one place, out from actual usage.

There are 6 protocols corresponding to HTTP methods: `GETRequestable`,
`POSTRequestable`, `PATCHRequestable`, `PUTRequestable`, `DELETERequestable`,
`HEADRequestable`. Just conform to one of them and you're ready to surf.

```swift
struct BoardIndexRequest: GETRequestable {

}

struct BoardCreateRequest: POSTRequestable {

}

struct BoardUpdateRequest: PATCHRequestable {

}

struct BoardDeleteRequest: DELETERequestable {

}
```

## Networking

`Networking` class is a core component of **Malibu** that sets shared headers,
pre-process and executes the actual HTTP request.

### Session configuration

`Networking` is created with `SessionConfiguration` which is just a wrapper
around `NSURLSessionConfiguration` and could represent 3 standard session types
+ 1 custom type:
* `Default` - configuration that uses the global singleton credential, cache and
cookie storage objects.
* `Ephemeral` - configuration with no persistent disk storage for cookies, cache
or credentials.
* `Background` - session configuration that can be used to perform networking
operations on behalf of a suspended application, within certain constraints.  
* `Custom(NSURLSessionConfiguration)` - if you're not satisfied with standard
types, your custom `NSURLSessionConfiguration` goes here.

### Initialization

It's pretty straightforward to create a new `Networking` instance:

```swift
// Simple networking with `Default` configuration and no base URL
let simpleNetworking = Networking()

let networking = Networking(
  // Every request made on this networking will be scoped by the base URL
  baseURLString: "https://surfwonderland.com/api/",
  // `Background` session configuration
  sessionConfiguration: .Background,
  // Custom `NSURLSessionDelegate` could set if needed
  sessionDelegate: self
)
```

### Additional headers

Additional headers will be used in the each request made on the networking:

```swift
let networking = Networking(baseURLString: "https://surfwonderland.com/api/")
networking.additionalHeaders = {
  ["Accept" : "application/json"]
}
```

Note that `Accept-Language`, `Accept-Encoding` and `User-Agent` headers are
included automatically.

### Pre-processing

```swift
let networking = Networking(baseURLString: "https://surfwonderland.com/api/")

// Use this closure to modify your `Requestable` value before `NSURLRequest`
// is created on base of it.
networking.beforeEach = { request in
  var request = request
  request.message.parameters["userId"] = "12345"

  return request
}

// Use this closure to modify generated `NSMutableURLRequest` object
// before the request is made.
networking.preProcessRequest = { (request: NSMutableURLRequest) in
  request.addValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9", forHTTPHeaderField: "token")
}
```

## Core

**Multiple Networking instances**

**Malibu** handles multiple networkings which you can register and resolve from
the container. Doing that, it's super easy to support several APIs and
configurations in your app.

```swift
let networking = Networking(baseURLString: "https://surfwonderland.com/api/")
networking.additionalHeaders = {
  ["Accept" : "application/json"]
}

// Register
Malibu.register("base", networking: networking)

// Perform request using specified networking configuration
Malibu.networking("base").GET(BoardsRequest(kind: 1, text: "classic"))
```

### Encoding
### Request
### Response
### Serialization
### Validation
### Mocks
### Logging

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

## Author

Hyper Interaktiv AS, ios@hyper.no

## Contributing

We would love you to contribute to **Malibu**, check the [CONTRIBUTING](https://github.com/hyperoslo/Malibu/blob/master/CONTRIBUTING.md) file for more info.

## License

**Malibu** is available under the MIT license. See the [LICENSE](https://github.com/hyperoslo/Malibu/blob/master/LICENSE.md) file for more info.
