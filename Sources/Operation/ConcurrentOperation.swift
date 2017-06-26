import Foundation

open class AsynchronousOperation: Operation {
  @objc enum State: Int {
    case ready
    case executing
    case finished
  }

  private static let stateKey = "state"
  private var rawState = State.ready

  @objc dynamic var state: State {
    get {
      return stateQueue.sync {
        return rawState
      }
    }
    set {
      willChangeValue(forKey: AsynchronousOperation.stateKey)
      stateQueue.sync(flags: .barrier) {
        rawState = newValue
      }
      didChangeValue(forKey: AsynchronousOperation.stateKey)
    }
  }

  private let stateQueue = DispatchQueue(
    label: "com.Malibu.ConcurrentOperation",
    attributes: .concurrent
  )

  var handleResponse: ((URLRequest?, Data?, URLResponse?, Error?) -> Void)?
  var makeUrlRequest: (() throws -> URLRequest)?

  public final override var isAsynchronous: Bool {
    return true
  }

  public final override var isReady: Bool {
    return super.isReady && state == .ready
  }

  public final override var isExecuting: Bool {
    return state == .executing
  }

  public final override var isFinished: Bool {
    return state == .finished
  }

  public final override func start() {
    super.start()

    guard !isCancelled else {
      state = .finished
      return
    }

    state = .executing
    execute()
  }

  // MARK: - KVO

  @objc private dynamic class func keyPathsForValuesAffectingIsReady() -> Set<String> {
    return [AsynchronousOperation.stateKey]
  }

  @objc private dynamic class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
    return [AsynchronousOperation.stateKey]
  }

  @objc private dynamic class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
    return [AsynchronousOperation.stateKey]
  }

  // MARK: - Execute

  /// Subclasses must implement this without calling `super`.
  open func execute() {
    fatalError("Subclasses must implement `execute`.")
  }

  /// Moves the operation into a completed state.
  public final func finish() {
    state = .finished
  }

  func extractUrlRequest() throws -> URLRequest {
    guard let makeUrlRequest = makeUrlRequest else {
      throw NetworkError.invalidRequestURL
    }
    return try makeUrlRequest()
  }
}
