# Per-Mac setup and calibration

EchoAtlas setup checks the built-in audio path and teaches the motion filter what normal resting movement looks like on this Mac. Run **Settings → Recalibrate** after changing the audio route or speaker volume, or when gestures become unreliable.

## Setup sequence

1. Check the selected sound frequency and microphone input while your hands rest. Setup starts at 20 kHz; if the signal is unsuitable, try 19 kHz or 18 kHz.
2. Hold your hand in its normal resting position while setup learns and verifies a movement threshold.
3. Follow the on-screen lift/lower prompts, then hold still when prompted to stop. Setup checks that a deliberate movement is detected and that returning to rest stops the gesture.
4. Save only when all checks pass and the speaker volume has remained steady. The saved threshold applies to the checked frequency and volume.

If setup is cancelled or fails, audio stops and no new profile is saved. A failure report can be saved manually; it contains aggregate measurements and setup metadata, not microphone recordings. Fix the indicated permission, volume, or route issue before trying again. A failed check alone does not establish that a Mac is unsupported.

## Validation limits

The 0.2 regression suite covers generated audio, setup thresholds, gesture decisions, and safe stopping. Those checks do not measure real-hand accuracy. Physical trials on the target Mac are still needed to assess speaker level and comfort, motion detection in different rooms, and behavior after audio-route or volume changes. External-app delivery and cross-device accuracy also need live testing. Distance and Position remain experimental estimates, not calibrated measurements.
