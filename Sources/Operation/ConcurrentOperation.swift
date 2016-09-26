import Foundation

class ConcurrentOperation: NSOperation {

  enum State: String {
    case Ready = "isReady"
    case Executing = "isExecuting"
    case Finished = "isFinished"
  }

  var state = State.Ready {
    willSet {
      willChangeValueForKey(newValue.rawValue)
      willChangeValueForKey(state.rawValue)
    }
    didSet {
      didChangeValueForKey(oldValue.rawValue)
      didChangeValueForKey(state.rawValue)
    }
  }

  override var asynchronous: Bool {
    return true
  }

  override var ready: Bool {
    return super.ready && state == .Ready
  }

  override var executing: Bool {
    return state == .Executing
  }

  override var finished: Bool {
    return state == .Finished
  }

  override func start() {
    guard !cancelled else {
      state = .Finished
      return
    }

    execute()
  }

  func execute() {
    state = .Executing
  }
}
