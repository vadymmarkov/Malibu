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
* [Usage](#usage)
  * [Core](#core)
  * [Networking](#networking)
  * [Encoding](#encoding)
  * [Request](#request)
  * [Response](#response)
  * [Serialization](#serialization)
  * [Validation](#validation)
  * [Mocks](#mocks)
  * [Logging](#logging)
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
  var message = Message(resource: "http://surfwonderland.com/api/boards")

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

If you still don't see any benefits or you're ready for even more magic,
keep scrolling down 😉...

## Usage

### Core
### Networking
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
