import Foundation

// Capture time travels with the audio, so a busy queue cannot turn an old
// gesture into a new command. This state is owned by the main thread.
struct InputFreshness {
    private var lastInput: Double
    init(startedAt: Double) { lastInput = startedAt }
    mutating func accept(capturedAt: Double, now: Double) -> Bool {
        guard capturedAt.isFinite, now.isFinite, capturedAt >= lastInput,
              now >= capturedAt, now-capturedAt <= 0.25 else { return false }
        lastInput = capturedAt
        return true
    }
    func expired(now: Double) -> Bool { !now.isFinite || now-lastInput >= 2 }
}

// Reservations span both analysis and UI delivery. A blocked main thread must
// not retain an unlimited number of microphone buffers or queued UI updates.
final class AudioDelivery {
    enum Reservation { case accepted, overloaded, cancelled }
    private let lock = NSLock()
    private var active = true
    private var pending = 0
    var isActive: Bool {
        lock.lock(); defer { lock.unlock() }
        return active
    }
    func reserve() -> Reservation {
        lock.lock(); defer { lock.unlock() }
        guard active else { return .cancelled }
        guard pending < 64 else { active = false; return .overloaded }
        pending += 1
        return .accepted
    }
    func complete() {
        lock.lock(); defer { lock.unlock() }
        pending -= 1
    }
    // Run on the receiving queue. A backlog failure can cancel this session
    // while results are waiting there, before its queued stop notification.
    func deliverIfActive(_ action: () -> Void) {
        defer { complete() }
        guard isActive else { return }
        action()
    }
    func cancel() {
        lock.lock(); defer { lock.unlock() }
        active = false
    }
}

func testAudioDelivery() {
    var clock = InputFreshness(startedAt:10)
    testCheck(!clock.expired(now:11),"A new session needs time to collect its first FFT window")
    testCheck(clock.expired(now:12.1),"Missing input must stop the session")
    testCheck(clock.accept(capturedAt:10.1,now:10.2),"Fresh input was rejected")
    testCheck(!clock.accept(capturedAt:10.05,now:10.2),"Out-of-order audio became a new gesture")
    testCheck(!clock.accept(capturedAt:10.3,now:14.3),"Delayed audio became a new gesture")
    testCheck(clock.expired(now:12.2),"Rejected input kept a dead session alive")
    testCheck(!clock.accept(capturedAt:.nan,now:10.2),"Invalid timestamps entered the session")
    let delivery = AudioDelivery()
    var accepted = 0, overloads = 0
    for _ in 0..<1000 {
        switch delivery.reserve() {
        case .accepted: accepted += 1
        case .overloaded: overloads += 1
        case .cancelled: break
        }
    }
    testCheck(accepted > 0 && accepted < 1000 && overloads == 1,"Blocked delivery was unbounded or repeatedly reported failure")
    var commands = 0
    // These results were enqueued before overload's stop notification. Even
    // if their timestamps remain fresh, an overloaded session cannot act.
    for _ in 0..<accepted { delivery.deliverIfActive { commands += 1 } }
    testCheck(commands == 0,"Queued audio emitted commands after backlog cancellation")
    testCheck(!delivery.isActive,"Overload resumed without an explicit restart")
    let restarted = AudioDelivery()
    testCheck(restarted.reserve() == .accepted,"New session inherited the old backlog")
    restarted.deliverIfActive { commands += 1 }
    testCheck(commands == 1,"Healthy delivery failed after a new session")
    testCheck(restarted.reserve() == .accepted,"Delivered reservation was not released")
    restarted.cancel(); restarted.deliverIfActive { commands += 1 }
    testCheck(commands == 1,"Queued audio emitted commands after Stop")
    testCheck(restarted.reserve() == .cancelled,"Stopped session accepted another callback")
    print("PASS audio timeout, capture-time freshness, bounded backlog, queued-result cancellation and restart")
}
