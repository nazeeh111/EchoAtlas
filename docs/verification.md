# Verification

Verified on Apple silicon macOS, 2026-09-22.

- Baseline and EchoAtlas both compile successfully using `./script/build_and_run.sh --build-only`.
- Both produce 20 PASS groups plus speaker-volume and volume-recalibration checks. Coverage includes FFT direction detection at 48/96 kHz, gallery return suppression, zoom reversal, stale-input stopping, double-push rejection/cooldown, echo-distance fixtures, two-speaker geometry, calibration validation, diagnostic classification, and scroll event encoding without posting events.
- The intentional self-test failure probe exits cleanly with status 1.
- Independent review found gesture/audio decision logic and stop/permission protections preserved. A reviewer reran the generated binary synthetic suite successfully.
- Shell syntax and diff whitespace checks passed.
- Independent extraction of the final ZIP passes strict code-signature verification. The build uses ad-hoc signing, not notarization.

## Remaining limits

Native visual inspection could not complete: the approved desktop launch tool hung twice, including after a session reset. No screenshot or successful interactive UI acceptance is claimed. Audio sensing was not started during this work. Real-hand accuracy, physical audio levels, external-app delivery, cross-device behavior, and battery use remain unverified.

A pre-existing Swift warning in SpeakerVolume.swift concerns a generic CoreAudio pointer. Baseline and redesigned builds both emit it; this presentation change does not alter that code.
