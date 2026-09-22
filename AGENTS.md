# EchoAtlas — agent guidance

## Scope and identity

- Work on the native **EchoAtlas Lab app** only, unless the user explicitly expands the task.
- GitHub repository: https://github.com/nazeeh111/EchoAtlas
- Default branch: `master`.
- App source: `work/Sonar/`; executable: `EchoAtlas`. Preserve the derivative bundle identifier `com.nazeeh.echoatlas` for permission continuity. This derivative has a separate bundle identity and must not stop or replace another app.
- User-facing app branding is `EchoAtlas`; the repository is `EchoAtlas`.
- Do not include EchoAtlasTheremin, the website, Blender projects, renders, or sibling-workspace files in Lab commits. These were previously pushed accidentally; the public-preparation history removes them.

## Before editing or committing

1. Verify the checkout with `git rev-parse --show-toplevel`, `git status --short`, and `git remote -v`.
2. Fetch the remote and compare history before pushing. A development checkout may lag behind commits pushed from another worktree; apparent local changes may already exist upstream.
3. Preserve uncommitted changes. Do not reset, clean, overwrite, or stash other work automatically to resolve divergence.
4. Stage explicit Lab paths and inspect the staged diff. Avoid `git add .` in mixed workspaces.
5. When asked to commit and push, use this repository and its `master` branch unless the user requests another branch. Use a normal fast-forward push, verify the remote commit, and report its hash. Never force-push without explicit authorization.
6. A feature request does not by itself require a commit or push.

## Build and run

- Native Swift/AppKit/SwiftUI app, built with `swiftc`; no Xcode project is required.
- Build and test without installing: `./script/build_and_run.sh --build-only`.
- Running without a flag installs to `~/Applications/EchoAtlas.app` and launches it after tests pass.
- Optional settings: `SONAR_SIGNING_IDENTITY`, `SONAR_INSTALL_PATH`, and `SONAR_PAPER_PATH`. No personal paths or certificate defaults belong in source.
- Use an explicit stable certificate and existing installation path when updating an established installation. Never replace its signature with ad-hoc signing silently.
- New developers can build ad-hoc without a certificate; Accessibility may need granting again after rebuilding.
- Do not commit certificates, private keys, generated bundles, ZIPs, or build output.
- A successful build or synthetic test does not prove live gesture accuracy. Report physical testing separately.

## Permissions and live operation

- Check existing Accessibility trust silently. Never repeatedly prompt when the user already enabled access.
- Preserve the bundle identifier, signing identity, and installed path during branding changes.
- Permission settings are opened only through explicit user action; do not reset TCC as a routine fix.
- Keep an immediate stop available. Sessions run until stopped; do not restore the old time limit.
- Use built-in audio, keep microphone samples local/in memory, and preserve Bluetooth exclusion.
- Rebuilds restart the app. Restore the user's selected mode, target, and direction preference where possible; make calibration state visible before resuming gestures.

## Gesture behavior

### Swipe

- The user's preferred mapping is **right-to-left sweep → Right Arrow / Next**, and **left-to-right sweep → Left Arrow / Previous**.
- This preference is currently enabled through the persisted `galleryWaveReversed` setting. Do not silently reset or double-invert it.
- Other apps sends arrow keys to the foreground app while focus is outside editable fields. Preserve these checks.
- `Previous` / `Next` buttons isolate app delivery from hand recognition. Sending a key successfully is not proof that the image changed; inspect the browser result.
- Prioritize one intentional navigation per sweep. Returning the hand must not immediately undo that navigation.
- Current detector baseline: 40 ms minimum evidence, at least 3 coherent samples, 650 ms cooldown, and 220 ms quiet re-arm. These are implementation thresholds, not guaranteed end-to-end latency.
- A previous attempt to shorten cooldown to 280 ms and quiet re-arm to 120 ms caused return strokes to navigate backward. Do not repeat that tuning without a better return-stroke model and live verification.
- Preserve tests for both directions, ambiguous motion, paused return strokes, and subsequent deliberate gestures.
- No mandatory wave recordings or per-direction training. Doppler sign is radial; it is not verified anatomical left/right tracking.

### Scroll

- Lift the hand to scroll; lower it to reset. Return motion must not reverse the page.
- Two short downward pushes switch the selected scroll direction.
- Keep scrolling smooth across brief uncertain readings while stopping safely on stale input.

## UI and experimental sensing

- Use brief instructions, obvious live state, and a visible countdown whenever calibration requires waiting.
- Preserve guards for empty signal/range arrays; empty-profile rendering previously caused a crash.
- Distance and Position are experimental echo estimates. Do not describe them as exact hand height, proven 3D positioning, or a point cloud.
- Keep synthetic tests separate from real microphone/speaker behavior and real-hand acceptance.
- Do not introduce camera tracking or claim finger-count recognition without an explicit scope change.

## Communication

- Be concise and direct. State what changed, what was checked, and what remains unverified.
- Honor the user's physical test results over synthetic success.
- When a regression follows tuning, identify the change and repair the behavior before adding more features.

## Public copy and media

- Use EchoAtlas branding and identify nazeeh111 as maintainer.
- Preserve factual limits: this is an experiment in progress, and synthetic tests do not establish physical gesture accuracy.
- Keep pet/hearing guidance and privacy details accurate.
- Preserve separate third-party media notices in THIRD_PARTY_NOTICES.md and assets/gallery/CREDITS.md.
- Do not start audio or grant permissions as part of a visual-only inspection.
