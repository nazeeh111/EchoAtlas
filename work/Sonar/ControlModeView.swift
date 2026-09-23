import AppKit
import SwiftUI

struct ControlModeView: View {
    @State private var showGestureGuide = false
    @ObservedObject var sonar: Sonar
    @ObservedObject var reader: Reader
    @ObservedObject var demo: DemoSession
    private var instruction: String {
        switch reader.mode {
        case .scroll: return "Lift your palm to scroll. Lower it to stop."
        case .gallery: return demo.wave.reversed ? "Sweep left for the next image. Sweep right to go back." : "Sweep right for the next image. Sweep left to go back."
        default: return reader.zoomReversed ? "Pull toward you to zoom in; push away to return." : "Push toward the screen to zoom in; pull back to return."
        }
    }
    private var detail: String {
        switch reader.mode {
        case .scroll: return reader.airTapEnabled ? "Two short downward pushes switch direction." : "Use the direction control to switch up or down."
        case .gallery: return "Pause briefly before returning your hand to avoid a second swipe."
        default: return reader.zoomReversed ? "A faster push returns the image to its starting size sooner." : "A faster pull returns the image to its starting size sooner."
        }
    }
    private var feedback: String {
        if sonar.starting { return "Starting audio…" }
        if !sonar.running { return "Ready when you are" }
        if sonar.status.contains("Calibrating") { return sonar.status }
        switch reader.mode {
        case .scroll: return reader.action
        case .gallery: return demo.feedback.hasPrefix("Start,") ? "Ready for a swipe" : demo.feedback
        default: return reader.zoomFeedback
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:12) {
                HStack(alignment:.top,spacing:16) {
                    practiceCanvas
                    guideRail.frame(width:244)
                }
                HStack(spacing:10) {
                    Text("MANUAL PRACTICE").font(.system(size:10,weight:.bold,design:.monospaced)).tracking(1.2).foregroundStyle(AtlasTheme.muted)
                    Rectangle().fill(AtlasTheme.line).frame(height:1)
                }
                HStack(spacing:10) { actions }.controlSize(.regular).frame(minHeight:32)
                Text("Practice here, or switch to another app that supports the same shortcuts. External control needs Accessibility access.")
                    .font(.caption).foregroundStyle(AtlasTheme.muted).fixedSize(horizontal:false,vertical:true)
            }
            .padding(.horizontal,28).padding(.bottom,16)
            .frame(maxWidth:1180)
            .frame(maxWidth:.infinity,alignment:.top)
        }.frame(maxWidth:.infinity,maxHeight:.infinity)
    }
    private var practiceCanvas: some View {
        VStack(alignment:.leading,spacing:0) {
            HStack {
                Text("PRACTICE CANVAS").font(.system(size:10,weight:.bold,design:.monospaced)).tracking(1.3).foregroundStyle(AtlasTheme.muted)
                Spacer()
                if reader.mode == .gallery {
                    Text("\(demo.galleryIndex + 1) / \(max(1,demo.photos.count))").monospacedDigit().font(.caption).foregroundStyle(AtlasTheme.muted)
                } else if reader.mode == .zoom {
                    Text("\(Int(reader.zoomScale*100))%").monospacedDigit().font(.caption).foregroundStyle(AtlasTheme.muted)
                }
            }.padding(.horizontal,16).padding(.vertical,13)
            Rectangle().fill(AtlasTheme.line).frame(height:1)
            GeometryReader { geometry in
                stage.frame(width:geometry.size.width,height:geometry.size.height)
            }.frame(height:348)
        }
        .background(AtlasTheme.card,in:RoundedRectangle(cornerRadius:15))
        .overlay(RoundedRectangle(cornerRadius:15).stroke(AtlasTheme.line,lineWidth:1))
        .clipShape(RoundedRectangle(cornerRadius:15))
        .frame(maxWidth:.infinity)
    }
    private var guideRail: some View {
        VStack(alignment:.leading,spacing:12) {
            Label("HOW TO MOVE",systemImage:"hand.draw").font(.system(size:10,weight:.bold,design:.monospaced)).tracking(1.2).foregroundStyle(AtlasTheme.accent)
            Text(instruction).font(.system(size:17,weight:.semibold,design:.rounded)).fixedSize(horizontal:false,vertical:true)
            Text(detail).font(.callout).foregroundStyle(AtlasTheme.muted).fixedSize(horizontal:false,vertical:true)
            Button { showGestureGuide = true } label: {
                Label("See gesture guide",systemImage:"arrow.up.right").font(.callout.weight(.semibold))
            }.buttonStyle(.plain).foregroundStyle(AtlasTheme.accent)
                .sheet(isPresented:$showGestureGuide) {
                    AppSheet(title:"\(reader.mode.rawValue) gesture",close:{ showGestureGuide = false },width:520,height:480) {
                        VStack(alignment:.leading,spacing:20) {
                            Text(instruction).font(.title3.weight(.semibold))
                            GestureGuideDiagram(mode:reader.mode).frame(height:250)
                            Text(detail).font(.callout).foregroundStyle(.secondary)
                            Text("EchoAtlas senses changes in reflected sound, so the illustration is a movement guide rather than measured hand tracking.")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            Rectangle().fill(AtlasTheme.line).frame(height:1)
            Text(sonar.starting || sonar.running ? feedback : "Keep still for the 3-second countdown, then move your hand.")
                .font(.callout.weight(.medium)).fixedSize(horizontal:false,vertical:true)
            Text(sonar.running ? "Stop anytime with ⌃⌥⌘Space" : "Sound starts only when you press Start.")
                .font(.caption).foregroundStyle(AtlasTheme.muted).fixedSize(horizontal:false,vertical:true)
            Spacer(minLength:2)
            options
        }
        .padding(17)
        .frame(maxWidth:.infinity,minHeight:390,alignment:.topLeading)
        .background(AtlasTheme.sidebar.opacity(0.5),in:RoundedRectangle(cornerRadius:15))
        .overlay(RoundedRectangle(cornerRadius:15).stroke(AtlasTheme.line,lineWidth:1))
    }
    @ViewBuilder private var options: some View {
        switch reader.mode {
        case .scroll:
            Button(reader.forward ? "Direction: down ↓" : "Direction: up ↑") { reader.switchDirection() }
                .buttonStyle(.bordered)
        case .gallery:
            WaveDirectionToggle(wave:demo.wave)
        default:
            Toggle("Reverse gestures",isOn:$reader.zoomReversed).toggleStyle(.switch).controlSize(.small)
        }
    }
    @ViewBuilder private var stage: some View {
        if reader.mode == .scroll {
            PaperView(reader:reader)
        } else {
            GeometryReader { geometry in
                ZStack {
                    AtlasTheme.sidebar.opacity(0.4)
                    if let image = previewImage {
                        Image(nsImage:image).resizable().scaledToFit()
                            .frame(width:geometry.size.width,height:geometry.size.height)
                            .scaleEffect(reader.mode == .zoom ? reader.zoomScale : 1)
                            .animation(.easeOut(duration:0.10),value:reader.zoomScale)
                    } else {
                        VStack(spacing:8) {
                            Image(systemName:"photo").font(.system(size:30))
                            Text("Open an image to practice").font(.callout)
                        }.foregroundStyle(AtlasTheme.muted)
                    }
                }.clipped()
            }
        }
    }
    private var previewImage: NSImage? {
        if reader.mode == .gallery {
            return demo.photos.isEmpty ? nil : demo.photos[demo.galleryIndex % demo.photos.count]
        }
        guard let url = Bundle.main.url(forResource:"material-metal",withExtension:"png",subdirectory:"Gallery") else { return nil }
        return NSImage(contentsOf:url)
    }
    @ViewBuilder private var actions: some View {
        switch reader.mode {
        case .scroll:
            Button("Scroll up") { reader.scroll(points:-180) }
            Button("Scroll down") { reader.scroll(points:180) }
            Spacer()
            Toggle("Air double-tap",isOn:$reader.airTapEnabled).toggleStyle(.switch).controlSize(.small)
        case .gallery:
            Button("Previous") { demo.perform("previous") }
            Button("Next") { demo.perform("next") }
            Spacer()
            Text("\(demo.galleryIndex+1) / \(max(1,demo.photos.count))").monospacedDigit().foregroundStyle(AtlasTheme.muted)
            Menu("Images") {
                Button("Open images…") { demo.openPhotos() }
                Button("Sample images") { demo.loadSamplePhotos() }
            }.fixedSize()
        default:
            Button("Zoom in") { reader.practiceZoom(3) }
            Button("Reset") { reader.practiceZoom(0) }
            Spacer()
            Text("\(Int(reader.zoomScale*100))%").monospacedDigit().foregroundStyle(AtlasTheme.muted)
        }
    }
}

private struct GestureGuideDiagram: View {
    let mode: DemoMode
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var movement: CGSize {
        switch mode {
        case .scroll: return CGSize(width:0,height:-65)
        case .gallery: return CGSize(width:100,height:0)
        default: return CGSize(width:45,height:-25)
        }
    }
    private var directionSymbol: String {
        switch mode {
        case .scroll: return "arrow.up.and.down"
        case .gallery: return "arrow.left.and.right"
        default: return "arrow.up.right.and.arrow.down.left"
        }
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius:16).fill(AtlasTheme.sidebar.opacity(0.55))
            VStack(spacing:14) {
                Image(systemName:directionSymbol).font(.system(size:34,weight:.light)).foregroundStyle(AtlasTheme.accent)
                ZStack {
                    RoundedRectangle(cornerRadius:14).stroke(AtlasTheme.line,lineWidth:2).frame(width:260,height:82)
                    Image(systemName:"keyboard").font(.system(size:42,weight:.ultraLight)).foregroundStyle(AtlasTheme.muted)
                    TimelineView(.animation(minimumInterval:1.0/30.0,paused:reduceMotion)) { timeline in
                        let phase = reduceMotion ? 0 : sin(timeline.date.timeIntervalSinceReferenceDate * .pi / 1.8)
                        Image(systemName:"hand.point.up.left.fill")
                            .font(.system(size:58)).foregroundStyle(AtlasTheme.ink)
                            .shadow(color:AtlasTheme.ink.opacity(0.12),radius:8,y:8)
                            .offset(x:movement.width/2 * phase,y:movement.height/2 * phase - 35)
                    }
                }
                Text(mode == .scroll ? "Lift · lower · repeat" : mode == .gallery ? "Sweep · pause · return" : "Push · pull · reset")
                    .font(.system(size:11,weight:.bold,design:.monospaced)).tracking(1).foregroundStyle(AtlasTheme.muted)
            }
        }
        .accessibilityElement(children:.ignore)
        .accessibilityLabel(mode == .scroll ? "Hand lifts and lowers above the keyboard" : mode == .gallery ? "Hand sweeps sideways above the keyboard" : "Hand pushes and pulls above the keyboard")
    }
}
