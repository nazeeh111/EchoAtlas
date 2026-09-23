import AppKit
import SwiftUI

enum AtlasTheme {
    static let background = Color(red:0.965,green:0.950,blue:0.920)
    static let sidebar = Color(red:0.91,green:0.88,blue:0.83)
    static let card = Color(red:0.995,green:0.987,blue:0.965)
    static let accent = Color(red:0.57,green:0.29,blue:0.19)
    static let ink = Color(red:0.16,green:0.20,blue:0.20)
    static let muted = Color(red:0.38,green:0.39,blue:0.36)
    static let line = Color(red:0.81,green:0.79,blue:0.73)
}

extension DemoMode {
    var symbol: String {
        switch self { case .zoom: return "plus.magnifyingglass"; case .scroll: return "scroll"; case .gallery: return "photo.on.rectangle"; case .position: return "scope"; case .distance: return "ruler"; case .signal: return "waveform.path" }
    }
    var subtitle: String {
        switch self {
        case .zoom: return "Take a closer look by moving your hand."
        case .scroll: return "Scroll through a page without touching your Mac."
        case .gallery: return "Browse images with a deliberate sweep."
        case .position: return "An experimental estimate from two speaker echoes."
        case .distance: return "Explore experimental echo-delay estimates."
        case .signal: return "Watch changes in the microphone signal."
        }
    }
}

struct ContentView: View {
    @State private var showSettings = false
    @State private var showHowItWorks = false
    @State private var showAudioSettings = false
    @State private var showDiagnostics = false
    @ObservedObject var sonar: Sonar
    @ObservedObject var reader: Reader
    init(sonar: Sonar) { self.sonar = sonar; reader = sonar.reader }
    private var versionLabel: String {
        let version = Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String ?? "Development"
        let build = Bundle.main.object(forInfoDictionaryKey:"CFBundleVersion") as? String
        return build.map { "Version \(version) (\($0))" } ?? "Version \(version)"
    }
    private var sessionActive: Bool { sonar.running || sonar.starting }
    private var isExternal: Bool { reader.usesExternalControl }
    private var sessionState: String {
        if sonar.starting { return "Starting" }
        if sonar.running {
            if sonar.calibrationRemaining != nil || sonar.status.contains("Calibrating") || sonar.status.contains("Measuring empty desk") { return "Calibrating" }
            return "Active"
        }
        return "Sound off"
    }
    private func choose(_ mode: DemoMode) {
        showSettings = false
        guard mode != reader.mode else { return }
        sonar.stop()
        reader.mode = mode
    }
    private var header: some View {
        HStack(spacing:18) {
            ZStack {
                RoundedRectangle(cornerRadius:12).fill(AtlasTheme.ink).frame(width:42,height:42)
                Image(systemName:"waveform.path").font(.system(size:22,weight:.medium)).foregroundStyle(AtlasTheme.background)
            }
            VStack(alignment:.leading,spacing:2) {
                Text("EchoAtlas").font(.system(size:22,weight:.bold,design:.rounded)).tracking(-0.5)
                Text("ACOUSTIC GESTURE CONTROL").font(.system(size:9,weight:.semibold,design:.monospaced)).tracking(1.2).foregroundStyle(AtlasTheme.muted)
            }
            Spacer(minLength:8)
            HStack(spacing:8) {
                Circle().fill(sonar.running ? Color(red:0.24,green:0.49,blue:0.34) : AtlasTheme.muted).frame(width:7,height:7)
                Text(sessionState).font(.callout.weight(.medium))
            }.foregroundStyle(AtlasTheme.ink).accessibilityElement(children:.combine)
            Button {
                if sessionActive { sonar.stop() } else { sonar.start() }
            } label: {
                Label(sessionActive ? "Stop session" : "Start session",systemImage:sessionActive ? "stop.fill" : "play.fill")
                    .font(.system(size:14,weight:.semibold)).frame(minWidth:118,minHeight:30)
            }
            .buttonStyle(.borderedProminent).tint(sessionActive ? Color(red:0.60,green:0.24,blue:0.20) : AtlasTheme.ink)
            .controlSize(.large)
            .accessibilityHint(sessionActive ? "Stops sound and gesture control immediately" : "Starts audio and calibration")
        }
        .padding(.horizontal,28).padding(.vertical,17)
        .background(AtlasTheme.card)
    }
    private func modeButton(_ mode: DemoMode) -> some View {
        let selected = !showSettings && reader.mode == mode
        return Button { choose(mode) } label: {
            HStack(spacing:7) {
                Image(systemName:mode.symbol).font(.system(size:13,weight:.semibold))
                Text(mode.rawValue).font(.system(size:13,weight:.semibold))
            }
            .frame(maxWidth:.infinity,minHeight:34)
            .foregroundStyle(selected ? AtlasTheme.card : AtlasTheme.ink)
            .background(selected ? AtlasTheme.ink : Color.clear,in:RoundedRectangle(cornerRadius:9))
            .contentShape(RoundedRectangle(cornerRadius:9))
        }.buttonStyle(.plain).accessibilityAddTraits(selected ? .isSelected : [])
    }
    private var navigation: some View {
        HStack(spacing:12) {
            Text("EXPLORE").font(.system(size:10,weight:.bold,design:.monospaced)).tracking(1.2).foregroundStyle(AtlasTheme.muted)
            ForEach(DemoMode.allCases) { mode in modeButton(mode) }
            Rectangle().fill(AtlasTheme.line).frame(width:1,height:22)
            Button { showSettings = true } label: {
                Image(systemName:"gearshape").font(.system(size:15,weight:.medium))
                    .frame(width:34,height:34)
                    .foregroundStyle(showSettings ? AtlasTheme.card : AtlasTheme.ink)
                    .background(showSettings ? AtlasTheme.ink : .clear,in:RoundedRectangle(cornerRadius:9))
            }.buttonStyle(.plain).accessibilityLabel("Settings").accessibilityAddTraits(showSettings ? .isSelected : [])
        }
        .padding(.horizontal,28).padding(.vertical,11)
        .background(AtlasTheme.sidebar.opacity(0.55))
    }
    private var settingsPage: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:24) {
                VStack(alignment:.leading,spacing:6) {
                    Text("PREFERENCES").font(.system(size:10,weight:.bold,design:.monospaced)).tracking(1.5).foregroundStyle(AtlasTheme.accent)
                    Text("Settings").font(.system(size:32,weight:.bold,design:.rounded))
                    Text("Tune the setup, inspect the audio path, or check diagnostics.").foregroundStyle(AtlasTheme.muted)
                }
                VStack(spacing:0) {
                    settingsRow("Recalibrate",symbol:"waveform.path",detail:"Find a sound setting and resting-hand tolerance for your Mac.") { sonar.stop(); sonar.setupOpen = true }
                    Divider().padding(.leading,52)
                    settingsRow("Audio settings",symbol:"slider.horizontal.3",detail:"Adjust the test sound and view your audio connection.") { showAudioSettings = true }
                    Divider().padding(.leading,52)
                    settingsRow("Run diagnostics",symbol:"stethoscope",detail:"Check what’s working and save a report for help.") { sonar.stop(); sonar.diagnosticsOpen = true; showDiagnostics = true }
                }
                .background(AtlasTheme.card,in:RoundedRectangle(cornerRadius:16))
                .overlay(RoundedRectangle(cornerRadius:16).stroke(AtlasTheme.line,lineWidth:1))
            }.padding(32).frame(maxWidth:850,alignment:.leading).frame(maxWidth:.infinity,alignment:.top)
        }.frame(maxWidth:.infinity,maxHeight:.infinity)
    }
    private func settingsRow(_ title:String,symbol:String,detail:String,action:@escaping () -> Void) -> some View {
        Button(action:action) {
            HStack(spacing:14) {
                Image(systemName:symbol).font(.system(size:19)).frame(width:24).foregroundStyle(AtlasTheme.accent)
                VStack(alignment:.leading,spacing:4) {
                    Text(title).font(.system(size:15,weight:.semibold)).foregroundStyle(AtlasTheme.ink)
                    Text(detail).font(.callout).foregroundStyle(AtlasTheme.muted).fixedSize(horizontal:false,vertical:true)
                }
                Spacer(minLength:12)
                Image(systemName:"chevron.right").font(.system(size:11,weight:.semibold)).foregroundStyle(AtlasTheme.muted)
            }.padding(20).frame(maxWidth:.infinity,alignment:.leading).contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
    private var notices: some View {
        VStack(spacing:8) {
            if sonar.starting || sonar.calibrationRemaining != nil {
                HStack(spacing:12) {
                    if let remaining = sonar.calibrationRemaining {
                        Text("\(max(1,Int(ceil(remaining))))").font(.system(size:24,weight:.bold,design:.rounded)).monospacedDigit().frame(width:32)
                    } else { ProgressView().frame(width:32) }
                    VStack(alignment:.leading,spacing:2) {
                        Text(sonar.starting ? "Starting microphone…" : "Calibrating · keep still").font(.callout.weight(.semibold))
                        Text(reader.mode == .distance || reader.mode == .position ? "Keep your hands away until calibration finishes." : "Hold your hand still. Move when the countdown finishes.").font(.caption)
                    }
                    Spacer()
                }.padding(.horizontal,16).padding(.vertical,10).background(AtlasTheme.accent.opacity(0.11),in:RoundedRectangle(cornerRadius:10))
                    .accessibilityElement(children:.combine)
            }
            if let warning = sonar.speakerWarning {
                Label(warning,systemImage:"speaker.slash.fill").font(.callout).frame(maxWidth:.infinity,alignment:.leading)
                    .padding(12).background(Color.orange.opacity(0.12),in:RoundedRectangle(cornerRadius:10))
            }
            if isExternal && !reader.accessibilityGranted {
                HStack {
                    Label("Allow Accessibility access to control other apps.",systemImage:"hand.raised")
                    Spacer()
                    Button("Open Settings") { reader.openAccessibilitySettings() }
                }.font(.callout).padding(12).background(Color.orange.opacity(0.12),in:RoundedRectangle(cornerRadius:10))
            }
            if !sessionActive && sonar.status != "Ready — sound is off" && sonar.status != "Stopped — sound is off" {
                Text(sonar.status).font(.callout).foregroundStyle(AtlasTheme.accent).frame(maxWidth:.infinity,alignment:.leading)
            }
        }.padding(.horizontal,28)
    }
    private var workspace: some View {
        VStack(spacing:0) {
            HStack(alignment:.bottom,spacing:20) {
                VStack(alignment:.leading,spacing:5) {
                    Text(reader.mode == .signal || reader.mode == .distance || reader.mode == .position ? "SIGNAL LAB" : "GESTURE STUDIO")
                        .font(.system(size:10,weight:.bold,design:.monospaced)).tracking(1.5).foregroundStyle(AtlasTheme.accent)
                    Text(reader.mode.rawValue).font(.system(size:32,weight:.bold,design:.rounded)).tracking(-0.6)
                }
                Spacer()
                Text(reader.mode.subtitle).font(.callout).foregroundStyle(AtlasTheme.muted).multilineTextAlignment(.trailing)
            }.padding(.horizontal,28).padding(.top,19).padding(.bottom,12)
            notices
            Group {
                switch reader.mode {
                case .position: PositionView(model:sonar.position,sonar:sonar)
                case .distance: DistanceView(model:sonar.distance,sonar:sonar)
                case .signal: SignalView(history:reader.signal,sonar:sonar)
                default: ControlModeView(sonar:sonar,reader:reader,demo:reader.demo)
                }
            }.frame(maxWidth:.infinity,maxHeight:.infinity)
        }
    }
    var body: some View {
        VStack(spacing:0) {
            header
            Rectangle().fill(AtlasTheme.line).frame(height:1)
            navigation
            Rectangle().fill(AtlasTheme.line).frame(height:1)
            if showSettings { settingsPage } else { workspace }
            HStack(spacing:14) {
                Text(sonar.running ? "Runs until you stop it." : "Start, then keep still for 3 seconds.")
                Spacer()
                Button("How it works") { showHowItWorks = true }.buttonStyle(.plain)
                Text("·")
                Text("ON-DEVICE AUDIO PROCESSING")
                Text("·")
                Text(versionLabel).textSelection(.enabled)
            }.font(.caption).foregroundStyle(AtlasTheme.muted).padding(.horizontal,28).padding(.vertical,12)
                .background(AtlasTheme.card)
        }
        .frame(minWidth:960,minHeight:680)
        .background(AtlasTheme.background)
        .foregroundStyle(AtlasTheme.ink)
        .tint(AtlasTheme.accent)
        .preferredColorScheme(.light)
        .sheet(isPresented:$sonar.setupOpen) {
            AppSheet(title:"Set up EchoAtlas",close:{ sonar.setupOpen = false },showDone:false,width:420,height:370) {
                DeviceSetupView(sonar:sonar,close:{ sonar.setupOpen = false })
            }
        }
        .sheet(isPresented:$showDiagnostics,onDismiss:{ sonar.diagnosticsOpen = false }) {
            AppSheet(title:"Diagnostics",close:{ showDiagnostics = false }) { DiagnosticsView(sonar:sonar) }
        }
        .sheet(isPresented:$showHowItWorks) {
            AppSheet(title:"How EchoAtlas works",close:{ showHowItWorks = false }) { HowItWorksView() }
        }
        .sheet(isPresented:$showAudioSettings) {
            AppSheet(title:"Audio settings",close:{ showAudioSettings = false }) { AudioSettingsView(sonar:sonar) }
        }
        .onExitCommand { sonar.stop() }
    }
}

struct WaveDirectionToggle: View {
    @ObservedObject var wave: WaveCalibration
    var body: some View { Toggle("Reverse directions",isOn:$wave.reversed).toggleStyle(.switch).controlSize(.small) }
}

final class AudioSettingsWindow {
    private static var window: NSWindow?
    static func show(_ sonar: Sonar) {
        if let window { window.makeKeyAndOrderFront(nil); return }
        let panel = NSWindow(contentRect:NSRect(x:0,y:0,width:440,height:500),styleMask:[.titled,.closable],backing:.buffered,defer:false)
        panel.title = "Audio Settings"; panel.isReleasedWhenClosed = false
        panel.contentView = NSHostingView(rootView:AudioSettingsView(sonar:sonar))
        window = panel; panel.center(); panel.makeKeyAndOrderFront(nil)
    }
}

struct AudioSettingsView: View {
    @ObservedObject var sonar: Sonar
    var body: some View {
        VStack(alignment:.leading,spacing:20) {
            Text("Use the built-in speakers and microphone. Stop EchoAtlas before changing the tone.").foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)
            Picker("Frequency",selection:$sonar.frequency) { ForEach([18000.0,19000.0,20000.0,21000.0],id:\.self) { Text("\(Int($0/1000)) kHz").tag($0) } }.disabled(sonar.running || sonar.starting)
            VStack(alignment:.leading) {
                Text("Signal level · \(String(format:"%.1f",sonar.level*100))%")
                Slider(value:$sonar.level,in:0.002...0.04).disabled(sonar.running || sonar.starting)
            }
            if let warning = sonar.speakerWarning { Text(warning).foregroundStyle(.orange).fixedSize(horizontal:false,vertical:true) }
            Spectrum(reading:sonar.reading).frame(height:95).background(Color.black.opacity(0.8)).clipShape(RoundedRectangle(cornerRadius:8))
            Text(sonar.status).font(.caption)
            Text(sonar.route).font(.caption).foregroundStyle(.secondary)
            Text("Experimental. Stop if the tone is audible or uncomfortable. Microphone audio is not saved.").font(.caption).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)
        }.frame(maxWidth:.infinity,alignment:.leading)
    }
}

// Shared structure for the three experimental instruments.
struct ExperimentIntro: View {
    let title: String
    let detail: String
    var body: some View {
        VStack(alignment:.leading,spacing:6) {
            Text(title).font(.system(size:16,weight:.medium))
            Text(detail).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)
        }.frame(maxWidth:.infinity,minHeight:48,alignment:.leading)
    }
}
struct ExperimentStatus: View {
    let text: String
    let symbol: String
    var body: some View {
        Label(text,systemImage:symbol).font(.callout).foregroundStyle(AtlasTheme.ink)
            .frame(maxWidth:.infinity,alignment:.leading).padding(12)
            .background(AtlasTheme.sidebar.opacity(0.45),in:RoundedRectangle(cornerRadius:10))
    }
}

enum ScreenLayout {
    static let width: CGFloat = 1180
    static let previewWidth: CGFloat = 960
    static let previewHeight: CGFloat = 350
    static let spacing: CGFloat = 14
    static let inset: CGFloat = 28
}

struct ScreenBody<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:ScreenLayout.spacing) { content() }
                .padding(ScreenLayout.inset)
                .frame(maxWidth:ScreenLayout.width)
                .frame(maxWidth:.infinity,alignment:.top)
        }.frame(maxWidth:.infinity,maxHeight:.infinity)
    }
}

struct ExperimentLayout<Toolbar: View, Stage: View, Actions: View, Status: View>: View {
    let title: String
    let detail: String
    @ViewBuilder var toolbar: () -> Toolbar
    @ViewBuilder var stage: () -> Stage
    @ViewBuilder var actions: () -> Actions
    @ViewBuilder var status: () -> Status
    var body: some View {
        ScreenBody {
            HStack(alignment:.top,spacing:16) {
                VStack(alignment:.leading,spacing:8) {
                    Text("ABOUT THIS VIEW").font(.system(size:10,weight:.bold,design:.monospaced)).tracking(1.2).foregroundStyle(AtlasTheme.accent)
                    ExperimentIntro(title:title,detail:detail)
                }
                Spacer(minLength:12)
                toolbar().frame(minHeight:32)
            }
            .padding(17).background(AtlasTheme.card,in:RoundedRectangle(cornerRadius:14))
            .overlay(RoundedRectangle(cornerRadius:14).stroke(AtlasTheme.line,lineWidth:1))
            VStack(alignment:.leading,spacing:0) {
                Text("LIVE INSTRUMENT").font(.system(size:10,weight:.bold,design:.monospaced)).tracking(1.2)
                    .foregroundStyle(AtlasTheme.muted).padding(.horizontal,16).padding(.vertical,12)
                Rectangle().fill(AtlasTheme.line).frame(height:1)
                GeometryReader { geometry in
                    stage().frame(width:geometry.size.width,height:geometry.size.height)
                }.frame(height:ScreenLayout.previewHeight)
            }
            .background(AtlasTheme.card,in:RoundedRectangle(cornerRadius:14))
            .overlay(RoundedRectangle(cornerRadius:14).stroke(AtlasTheme.line,lineWidth:1))
            .clipShape(RoundedRectangle(cornerRadius:14))
            actions().frame(minHeight:32)
            status()
        }
    }
}

struct HowItWorksView: View {
    var body: some View {
        VStack(alignment:.leading,spacing:24) {
            tip("Sound and movement", "EchoAtlas plays a steady tone through your Mac’s speakers. Your hand reflects it back to the microphone. Moving toward the Mac raises the reflected frequency; moving away lowers it. This Doppler shift lets EchoAtlas detect movement.")
            tip("Start", "Choose a control and press Start. Keep still for the three-second countdown, then move your palm above the keyboard. Practice in EchoAtlas or switch to the app you want to control.")
            tip("Scroll", "Lift your palm to scroll and lower it to stop. Enable Air double-tap to change direction with two quick downward pushes.")
            tip("Swipe", "Sweep sideways to change photos. Pause before returning your hand. Reverse directions swaps the mapping. External viewers need left/right arrow-key support.")
            tip("Zoom", "Push toward the screen to zoom in and pull back to zoom out. Reverse gestures swaps the mapping. External apps need Command-plus/minus support; browsers return to 100%.")
            tip("Sound and privacy", "Use the built-in speakers and microphone. Stop if the tone feels uncomfortable, and use it away from pets. Audio is processed locally. This is an experiment in progress.")
        }.frame(maxWidth:.infinity,alignment:.leading)
    }
    private func tip(_ title:String,_ body:String) -> some View {
        VStack(alignment:.leading,spacing:8) {
            Text(title).font(.headline)
            Text(body).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)
        }
    }
}

struct AppSheet<Content: View>: View {
    let title: String
    let close: () -> Void
    var showDone = true
    var width: CGFloat = 500
    var height: CGFloat = 560
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(spacing:0) {
            HStack {
                Text(title).font(.system(size:20,weight:.semibold))
                Spacer()
                Button(action:close) { Image(systemName:"xmark").font(.system(size:13,weight:.semibold)).frame(width:30,height:30) }
                    .buttonStyle(.borderless).accessibilityLabel("Close \(title)")
            }.padding(.horizontal,24).padding(.vertical,16)
            Divider()
            ScrollView { content().padding(24).frame(maxWidth:.infinity,alignment:.leading) }
                .frame(maxWidth:.infinity,maxHeight:.infinity)
            if showDone {
                Divider()
                HStack { Spacer(); Button("Done",action:close).buttonStyle(.borderedProminent).controlSize(.large).keyboardShortcut(.cancelAction) }.padding(16)
            }
        }.frame(width:width,height:height).background(Color(nsColor:.windowBackgroundColor))
    }
}

private struct SidebarActionLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 8) {
            configuration.icon.frame(width: 22, alignment: .center)
            configuration.title
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
