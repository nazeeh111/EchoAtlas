import Foundation

// Deterministic PCM replay through the real FFT, rest filter and gesture logic.
// No microphone, speakers, permission requests or system input events are used.
func testSensingReplay() {
    for rate in [48000.0,96000.0] {
        let analyzer = Analyzer(rate:rate,tone:20000)
        var wave = ImmediateWave(), zoom = ZoomMotion(), scroll = ScrollMotion()
        var freshness = InputFreshness(startedAt:0)
        var swipes: [String] = [], zooms: [Int] = []
        var travel = 0.0, actionsDuringCalibration = 0
        let total = Int(7 * rate / Double(analyzer.hop))
        for frame in 0..<total {
            let pcm = (0..<analyzer.n).map { i -> Float in
                let t = Double(frame*analyzer.hop+i)/rate
                // One intentional approach, its immediate return, then stillness.
                let offset = (3.2..<3.5).contains(t) ? 180.0 : (3.5..<3.8).contains(t) ? -180.0 : 0
                return Float(0.05*sin(2 * .pi * 20000*t) + (offset == 0 ? 0 : 0.004*sin(2 * .pi * (20000+offset)*t)))
            }
            let time = Double(frame*analyzer.hop+analyzer.n)/rate
            let raw = analyzer.analyze(pcm)
            let reading = RestMotionFilter.apply(raw,threshold:RestMotionFilter.minimum)
            testCheck(freshness.accept(capturedAt:time,now:time+0.01),"Healthy replay was rejected")
            if let event = wave.feed(reading,now:time) {
                swipes.append(event); if raw.calibrationRemaining != nil { actionsDuringCalibration += 1 }
            }
            if let event = zoom.feed(reading,now:time,reversed:false) {
                zooms.append(event); if raw.calibrationRemaining != nil { actionsDuringCalibration += 1 }
            }
            scroll.feed(direction:reading.direction,strength:reading.strength,now:time)
            let points = scroll.step(dt:Double(analyzer.hop)/rate,now:time)
            travel += points
            if raw.calibrationRemaining != nil && points != 0 { actionsDuringCalibration += 1 }
            testCheck(reading.spectrum.allSatisfy(\.isFinite) && reading.strength.isFinite,"Nonfinite FFT output")
        }
        testCheck(actionsDuringCalibration == 0,"Calibration emitted gesture commands")
        testCheck(swipes == ["next"],"PCM sweep and return produced \(swipes) at \(rate)")
        testCheck(zooms == [3,-1,-1,0],"PCM zoom did not return to its initial size: \(zooms) at \(rate)")
        testCheck(travel > 0 && scroll.velocity == 0,"PCM scroll failed to move and settle")
        let before = travel
        // Replay an old movement frame after a UI stall. The real delivery gate
        // must reject it before any detector receives it, and then time out.
        if freshness.accept(capturedAt:7.2,now:11.2) {
            scroll.feed(direction:"MOVING AWAY",strength:0.004,now:11.2)
            travel += scroll.step(dt:0.02,now:11.2)
        }
        testCheck(travel == before && freshness.expired(now:11.2),"Expired input produced new scroll movement")
        let fresh = Analyzer(rate:rate,tone:20000)
        let still = (0..<fresh.n).map { Float(0.05*sin(2 * .pi * 20000*Double($0)/rate)) }
        let restarted = fresh.analyze(still)
        testCheck(restarted.calibrationRemaining != nil,"Restart skipped the new baseline")
        print("PASS PCM replay at \(Int(rate)) Hz: calibration, swipe return, zoom reset, scroll settle, stale rejection, restart")
    }
}
