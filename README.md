# EchoAtlas

**Development history:** Developed locally using Git before publication. These projects were published to GitHub together, so similar upload dates do not indicate when development began.

Control your Mac with hand gestures using its built-in speakers and microphone. A native macOS workspace for scrolling, photo navigation, zoom, and experimental acoustic sensing.

Apple silicon · macOS 14 or later · local audio processing.

## Download

[Download EchoAtlas for Apple silicon](https://github.com/nazeeh111/EchoAtlas/releases/latest/download/EchoAtlas.zip) · [SHA-256 checksum](https://github.com/nazeeh111/EchoAtlas/releases/latest/download/EchoAtlas.zip.sha256)

Requires an Apple silicon Mac running macOS 14 or later. Unzip the download and move `EchoAtlas.app` to Applications. This build is ad-hoc signed and is **not Apple-notarized**, so macOS may block its first launch. Review the release notes before deciding whether to allow it in System Settings → Privacy & Security. The source-build option below is also available.

Microphone access is requested when you start sensing. Accessibility access is needed only to control other apps; the app has local practice modes. Existing permissions and preferences from another app are separate.

## Build and run

Install Apple’s command-line developer tools if needed (`xcode-select --install`), then:

```sh
git clone https://github.com/nazeeh111/EchoAtlas.git
cd EchoAtlas
./script/build_and_run.sh --build-only
open outputs/EchoAtlas.app
```

The build runs the synthetic regression suite before producing `outputs/EchoAtlas.app` and `outputs/EchoAtlas.zip`. The app uses free ad-hoc signing. macOS may require permission for a locally built app. No paid account, API, or service is needed.

To build, test, install to `~/Applications/EchoAtlas.app`, and launch, run `./script/build_and_run.sh` without flags. The distinct app identity keeps other apps and their settings separate.

## Your workspace

- **Scroll:** lift your hand to scroll; lower it to reset. Enable **Air double-tap** and push down twice to reverse direction.
- **Swipe:** sweep sideways to move through photos. Pause before returning your hand. Reverse directions when needed.
- **Zoom:** push toward the screen to zoom in and pull back to return. A direction switch reverses the mapping.
- **Signal:** inspect microphone frequency changes and motion visualizations.
- **Distance and Position:** explore experimental echo estimates.

Choose a mode in the top navigation. The gesture guide explains the motion, and the practice canvas lets you try manual controls before starting sound. Click **Start**, hold still through calibration, then move your hand. Switch to another app to control compatible content.

Microphone permission is needed for sensing; Accessibility permission is needed to control other apps. Stop immediately with the visible **Stop** button, menu bar controls, Escape in the app, or **Control–Option–Command–Space**. Sessions continue until stopped. EchoAtlas also stops when the Mac sleeps, microphone readings disappear, or audio processing falls behind. It explains the failure and waits for you to press Start, which runs a fresh calibration.

## Audio and calibration

Use the built-in speakers and microphone. Bluetooth audio remains excluded. Stop if the tone is audible or uncomfortable.

The default tone is 20 kHz. [Dogs and cats can hear this frequency](https://www.lsu.edu/vetmed/deafness/hearingrange.php). Use EchoAtlas away from pets and stop if they seem uncomfortable. Pet safety and sound levels across Mac models still need evaluation.

**Settings → Recalibrate** runs a 10-second sound check and guided movement/stopping checks. Settings are saved only after checks pass; cancellation or failure preserves the current settings. Changing volume during a session restarts calibration. Resting-motion tolerance is applied only at the tested frequency and volume.

## How sensing works

1. Speakers emit a steady high-frequency tone, 20 kHz by default.
2. Sound reflects off your moving hand and reaches the microphone.
3. Motion toward the audio hardware raises the reflected frequency; motion away lowers it. This frequency change is the **Doppler effect**.
4. The app identifies patterns in the signal and maps recognized gestures to commands.

Sideways motion is inferred from the acoustic signal. Room reflections and other movement can interfere. This approach uses sound and echoes, without camera tracking.

## Diagnostics and privacy

Microphone samples stay local, in memory, and are discarded after processing. Recent motion readings and optional verification reports use `~/Library/Caches/EchoAtlas/`.

**Settings → Run diagnostics** checks signal quality and simulates gesture decisions while gesture control is paused. Save a readable report if needed. Reports contain system/app versions, permission status, session-local route numbers, volume, audio callback errors, and summary measurements. They contain no recorded audio, screenshots, window titles, device names, serial numbers, or file paths. Nothing is uploaded automatically.

## Verification and limits

The preserved synthetic suite covers audio transforms, gesture decisions, return suppression, calibration, diagnostic handling, volume changes, and safe stopping. See [verification details](docs/verification.md).

Physical gesture accuracy, speaker levels, and battery use vary with the Mac and room. Live-hand acceptance and cross-device accuracy testing are still needed. Distance and Position remain experimental estimates. Source builds are ad-hoc signed; the optional release-packaging script requires your own signing/notarization setup and is not needed for local use.

Maintained by **nazeeh111**. See [component and asset notices](THIRD_PARTY_NOTICES.md).
