# Usage and development notes

## Start and stop

Choose a mode in the top navigation and press **Start**. Keep your hand still through the calibration countdown, then try the gesture above the keyboard. Use the visible **Stop session** button, the menu bar, or **Control–Option–Command–Space** to stop. Switching modes also stops the current session.

**Settings → Recalibrate** checks the built-in speaker and microphone, then checks resting movement, a deliberate gesture, and stopping. Save settings only after the checks pass. A failed or cancelled setup saves nothing new.

## Scroll

Select **Scroll** to practice with the bundled EchoAtlas gesture guide. The **Scroll up** and **Scroll down** buttons move the page without audio. After starting, lift your palm to scroll and lower it to stop. Use the direction control to switch direction; **Air double-tap** enables two short downward pushes as another way to switch.

## Swipe

Select **Swipe** to browse the three bundled material studies. Use **Images → Open images…** to choose local images, or **Sample images** to restore the bundled set. The **Previous** and **Next** buttons work without audio. With sensing on, sweep sideways and pause before returning your hand. **Reverse directions** changes which sweep advances the gallery.

## Zoom

Select **Zoom** to inspect the bundled metal study. **Zoom in** and **Reset** work without audio. With sensing on, push toward the screen to zoom in and pull back to return. **Reverse gestures** swaps those actions.

To control another app, bring compatible content to the front and grant Accessibility access. Scroll sends scroll events, Swipe sends left/right arrow keys, and Zoom uses Command-plus/minus. Browser zoom returns to 100% when EchoAtlas sends its reset. App behavior depends on the shortcuts it supports.

## Signal, Distance, and Position

**Signal** displays microphone frequency changes and motion visualizations. **Distance** and **Position** display experimental echo-delay estimates, not calibrated measurements. Room reflections, device response, and alignment affect those estimates.

## Developer options

Source files are in `work/Sonar/`. Build and run the local checks with `./script/build_and_run.sh --build-only`. The script supports `SONAR_SIGNING_IDENTITY` for signing, `SONAR_INSTALL_PATH` for the install location, and `SONAR_PAPER_PATH` to supply a replacement PDF for the bundled gesture guide. The `--verify-audio` and `--verify-scroll` options run focused local checks.
