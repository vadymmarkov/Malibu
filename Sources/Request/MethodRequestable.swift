public protocol GETRequestable: Requestable {}
public protocol POSTRequestable: Requestable {}
public protocol PUTRequestable: Requestable {}
public protocol PATCHRequestable: Requestable {}
public protocol DELETERequestable: Requestable {}
public protocol HEADRequestable: Requestable {}

public extension GETRequestable {

  var method: Method {
    return .get
  }

  var contentType: ContentType {
    return .query
  }

  var etagPolicy: ETagPolicy {
    return .enabled
  }
}

public extension POSTRequestable {

  var method: Method {
    return .post
  }

  var contentType: ContentType {
    return .json
  }

  var etagPolicy: ETagPolicy {
    return .disabled
  }
}

public extension PUTRequestable {

  var method: Method {
    return .put
  }

  var contentType: ContentType {
    return .json
  }

  var etagPolicy: ETagPolicy {
    return .enabled
  }
}

public extension PATCHRequestable {

  var method: Method {
    return .patch
  }

  var contentType: ContentType {
    return .json
  }

  var etagPolicy: ETagPolicy {
    return .enabled
  }
}

public extension DELETERequestable {

  var method: Method {
    return .delete
  }

  var contentType: ContentType {
    return .query
  }

  var etagPolicy: ETagPolicy {
    return .disabled
  }
}

public extension HEADRequestable {

  var method: Method {
    return .head
  }

  var contentType: ContentType {
    return .query
  }

  var etagPolicy: ETagPolicy {
    return .disabled
  }
}
