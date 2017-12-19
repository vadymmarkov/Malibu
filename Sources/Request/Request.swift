import Foundation

// MARK: - Request

public struct Request: Equatable {
  public enum Task {
    case data
    case upload(data: Data?)
  }
  public let task: Task
  public let method: Method
  public let resource: URLStringConvertible
  public let parameters: [String: Any]
  public let headers: [String: String]
  public let contentType: ContentType
  public let etagPolicy: EtagPolicy
  public let storePolicy: StorePolicy
  public let cachePolicy: NSURLRequest.CachePolicy

  public init(method: Method,
              resource: URLStringConvertible,
              contentType: ContentType,
              task: Task = .data,
              parameters: [String: Any] = [:],
              headers: [String: String] = [:],
              etagPolicy: EtagPolicy = .disabled,
              storePolicy: StorePolicy = .unspecified,
              cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy) {
    self.task = task
    self.method = method
    self.resource = resource
    self.contentType = contentType
    self.parameters = parameters
    self.headers = headers
    self.etagPolicy = etagPolicy
    self.storePolicy = storePolicy
    self.cachePolicy = cachePolicy
  }
}

// MARK: - Method helpers

public extension Request {

  public static func get(_ resource: URLStringConvertible,
                         parameters: [String: Any] = [:],
                         headers: [String: String] = [:],
                         etagPolicy: EtagPolicy = .enabled,
                         storePolicy: StorePolicy = .unspecified,
                         cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy) -> Request {
    return Request(
      method: .get,
      resource: resource,
      contentType: .query,
      parameters: parameters,
      headers: headers,
      etagPolicy: .enabled,
      storePolicy: storePolicy,
      cachePolicy: cachePolicy
    )
  }

  public static func post(_ resource: URLStringConvertible,
                          contentType: ContentType = .json,
                          parameters: [String: Any] = [:],
                          headers: [String: String] = [:],
                          storePolicy: StorePolicy = .unspecified,
                          cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy) -> Request {
    return Request(
      method: .post,
      resource: resource,
      contentType: contentType,
      parameters: parameters,
      headers: headers,
      etagPolicy: .disabled,
      storePolicy: storePolicy,
      cachePolicy: cachePolicy
    )
  }

  public static func put(_ resource: URLStringConvertible,
                         contentType: ContentType = .json,
                         parameters: [String: Any] = [:],
                         headers: [String: String] = [:],
                         etagPolicy: EtagPolicy = .enabled,
                         storePolicy: StorePolicy = .unspecified,
                         cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy) -> Request {
    return Request(
      method: .put,
      resource: resource,
      contentType: contentType,
      parameters: parameters,
      headers: headers,
      etagPolicy: etagPolicy,
      storePolicy: storePolicy,
      cachePolicy: cachePolicy
    )
  }

  public static func patch(_ resource: URLStringConvertible,
                           contentType: ContentType = .json,
                           parameters: [String: Any] = [:],
                           headers: [String: String] = [:],
                           etagPolicy: EtagPolicy = .enabled,
                           storePolicy: StorePolicy = .unspecified,
                           cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy) -> Request {
    return Request(
      method: .patch,
      resource: resource,
      contentType: contentType,
      parameters: parameters,
      headers: headers,
      etagPolicy: etagPolicy,
      storePolicy: storePolicy,
      cachePolicy: cachePolicy
    )
  }

  public static func delete(_ resource: URLStringConvertible,
                            contentType: ContentType = .query,
                            parameters: [String: Any] = [:],
                            headers: [String: String] = [:],
                            etagPolicy: EtagPolicy = .disabled,
                            storePolicy: StorePolicy = .unspecified,
                            cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy) -> Request {
    return Request(
      method: .delete,
      resource: resource,
      contentType: contentType,
      parameters: parameters,
      headers: headers,
      etagPolicy: etagPolicy,
      storePolicy: storePolicy,
      cachePolicy: cachePolicy
    )
  }

  public static func head(_ resource: URLStringConvertible,
                          contentType: ContentType = .query,
                          parameters: [String: Any] = [:],
                          headers: [String: String] = [:],
                          etagPolicy: EtagPolicy = .disabled,
                          storePolicy: StorePolicy = .unspecified,
                          cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy) -> Request {
    return Request(
      method: .head,
      resource: resource,
      contentType: contentType,
      parameters: parameters,
      headers: headers,
      etagPolicy: etagPolicy,
      storePolicy: storePolicy,
      cachePolicy: cachePolicy
    )
  }

  public static func upload(data: Data,
                            to resource: URLStringConvertible,
                            method: Method = .post,
                            contentType: ContentType = .formURLEncoded,
                            headers: [String: String] = [:],
                            storePolicy: StorePolicy = .unspecified,
                            cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy) -> Request {
    return Request(
      method: method,
      resource: resource,
      contentType: contentType,
      task: .upload(data: data),
      parameters: [:],
      headers: headers,
      etagPolicy: .disabled,
      storePolicy: storePolicy,
      cachePolicy: cachePolicy
    )
  }

  public static func upload(multipartParameters: [String: String],
                            to resource: URLStringConvertible,
                            method: Method = .post,
                            headers: [String: String] = [:],
                            storePolicy: StorePolicy = .unspecified,
                            cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy) -> Request {
    return Request(
      method: method,
      resource: resource,
      contentType: .multipartFormData,
      task: .upload(data: nil),
      parameters: multipartParameters,
      headers: headers,
      etagPolicy: .disabled,
      storePolicy: storePolicy,
      cachePolicy: cachePolicy
    )
  }
}

// MARK: - Url helpers

public extension Request {
  func toUrlRequest(baseUrl: URLStringConvertible? = nil,
                    additionalHeaders: [String: String] = [:]) throws -> URLRequest {
    let prefix = baseUrl?.urlString ?? ""

    let url: URL = try {
        if let resourceUrl = resource as? URL {
            return resourceUrl
        } else {
            return try concatURL(baseUrl: baseUrl?.urlString)
        }
    }()

    let requestUrl = try buildUrl(from: url)
    var request = URLRequest(url: requestUrl)

    request.httpMethod = method.rawValue
    request.cachePolicy = cachePolicy

    if let contentTypeHeader = contentType.header {
      request.setValue(contentTypeHeader, forHTTPHeaderField: "Content-Type")
    }

    var bodyData: Data?

    if case .upload(let data) = task, let uploadData = data {
      bodyData = uploadData
    } else {
      if let encoder = parameterEncoders[contentType] {
        bodyData = try encoder.encode(parameters: parameters)
      } else if let encoder = contentType.encoder {
        bodyData = try encoder.encode(parameters: parameters)
      }
    }

    request.httpBody = bodyData

    if let body = bodyData, contentType == .multipartFormData {
      request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
    }

    [additionalHeaders, headers].forEach {
      $0.forEach { key, value in
        request.setValue(value, forHTTPHeaderField: key)
      }
    }

    if etagPolicy == .enabled {
      if let etag = EtagStorage().get(etagKey(prefix: prefix)) {
        request.setValue(etag, forHTTPHeaderField: "If-None-Match")
      }
    }

    return request
  }

  func buildUrl(from string: String) throws -> URL {
    guard let url = URL(string: string) else {
      throw NetworkError.invalidRequestURL
    }

    return try buildUrl(from: url)
  }

  func buildUrl(from url: URL) throws -> URL {
    guard contentType == .query && !parameters.isEmpty else {
      return url
    }

    guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return url
    }

    let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "")
      + QueryBuilder().buildQuery(from: parameters)

    urlComponents.percentEncodedQuery = percentEncodedQuery

    guard let queryURL = urlComponents.url else {
      throw NetworkError.invalidRequestURL
    }

    return queryURL
  }

  func etagKey(prefix: String = "") -> String {
    return "\(method.rawValue)\(prefix)\(resource.urlString)\(parameters.description)"
  }

  var key: String {
    return "\(method.rawValue) \(resource.urlString)"
  }

  func concatURL(baseUrl: URLStringConvertible?) throws -> URL {
    let url: URL?

    if let baseUrl = baseUrl {
      var base = baseUrl.urlString
      if !base.hasSuffix("/") {
        base.append("/")
      }

      var path = resource.urlString
      if path.hasPrefix("/") {
        path.remove(at: path.startIndex)
      }

      url = URL(string: "\(base)\(path)")
    } else {
      url = URL(string: resource.urlString)
    }

    guard let fullUrl = url else {
      throw NetworkError.invalidRequestURL
    }

    return fullUrl
  }
}

// MARK: - Equatable

public func == (lhs: Request, rhs: Request) -> Bool {
  return lhs.method == rhs.method
    && lhs.resource.urlString == rhs.resource.urlString
    && (lhs.parameters as NSDictionary).isEqual(to: rhs.parameters)
    && lhs.headers == rhs.headers
    && lhs.contentType == rhs.contentType
    && lhs.etagPolicy == rhs.etagPolicy
    && lhs.storePolicy == rhs.storePolicy
    && lhs.cachePolicy == rhs.cachePolicy
}
