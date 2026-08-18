# iAmYansi Holo — Prototype

Owner-only R&D prototype for a palm/wrist spatial-interface device.

## V0 architecture

- ESP32-class controller
- IMU for orientation/gesture sensing
- proximity/ToF sensor for hand interaction
- RGB status light / Yansi presence indicator
- haptic motor output
- BLE/Wi-Fi link to iAmYansi host
- external optical module placeholder (pico-projector / optical combiner / AR display)
- microphone/audio module placeholder

## Control loop

1. Wake / presence detection
2. Read IMU + proximity data
3. Classify simple gestures
4. Send gesture events to iAmYansi
5. Receive display/audio/haptic commands
6. Drive local feedback

This is a hardware-control foundation, not a claim of a true free-air hologram. The optical subsystem will be selected and prototyped separately.

## Safety

Do not drive a laser/optical emitter directly from this firmware. Any laser or high-power optical subsystem requires a separately engineered, certified driver and appropriate eye-safety controls.
