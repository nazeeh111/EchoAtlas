# Verification

Verified on Apple silicon macOS, 2026-09-23.

- Baseline and EchoAtlas both compile successfully using `./script/build_and_run.sh --build-only`.
- The current build produces 23 PASS groups plus speaker-volume and volume-recalibration checks. The earlier baseline produced 20 PASS groups. Coverage includes FFT direction detection at 48/96 kHz, gallery return suppression, zoom reversal, stale-input stopping, double-push rejection/cooldown, echo-distance fixtures, two-speaker geometry, calibration validation, diagnostic classification, and scroll event encoding without posting events.
- The intentional self-test failure probe exits cleanly with status 1.
- The earlier 2026-09-22 independent review found gesture/audio decision logic and stop/permission protections preserved. A reviewer reran that generated binary synthetic suite successfully.
- Shell syntax and diff whitespace checks passed.
- Independent standard ZIP extraction passes strict code-signature verification and all 23 PASS groups. Packaging omits AppleDouble metadata sidecars, which otherwise become extra sealed resources with generic ZIP extractors. Every build now extracts and verifies its ZIP before any installation. The build uses ad-hoc signing, not notarization.

## Audio failure and replay checks

A deterministic replay now sends generated PCM (raw audio samples) through the actual FFT analyzer, resting-motion filter, and swipe, zoom, and scroll detectors at both 48 kHz and 96 kHz. It checks that calibration emits no commands, a sweep and its immediate return produce one swipe, zoom returns to its starting size, scrolling settles, delayed input cannot restart movement, and a restart creates a fresh baseline. These are idealized synthetic signals, not recorded hands or evidence of real-world accuracy.

The delivery checks cover missing input, delayed and out-of-order timestamps, a bounded backlog, cancellation, and a clean new session. Independent review reproduced a queue-ordering gap: already queued fresh results could run before the overload stop notification. Delivery now checks cancellation before entering the result handler and between readings, with a regression check that queued results emit no commands after overload or Stop. Before the fix, replaying the original scroll-delivery behavior showed that a four-second-old reading produced 2.13486 new scroll points. Normal sensing now carries capture times into detectors, rejects delayed input, and stops after two seconds without an accepted reading (checked every 250 ms). Outstanding callbacks are bounded across both the analysis queue and main-thread delivery. A sleep notification stops sensing and pending permission requests; waking does not restart audio.

The build and tests never start sensing or post system input events. The sleep-notification wiring and actual device loss remain source-inspected rather than physically exercised.

## Remaining limits

The version 0.2.0 ZIP was extracted separately, its strict code signature verified, and the native app inspected with sensing stopped. All six modes were reached. Manual scrolling changed the document position; gallery navigation advanced through the three replacement images; Zoom changed from 100% to 150% and reset to 100%; reversing gestures updated both the side guide and its sheet. Position settings opened successfully. Screenshots confirmed the new horizontal navigation, cream/copper layout, image presentation, and bundled guide. Audio sensing was not started during this work. Real-hand accuracy, physical audio levels, external-app delivery, cross-device behavior, and battery use remain unverified.

A pre-existing Swift warning in SpeakerVolume.swift concerns a generic CoreAudio pointer. Baseline and redesigned builds both emit it; this presentation change does not alter that code.
