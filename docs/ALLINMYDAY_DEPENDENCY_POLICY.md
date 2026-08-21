# Allinmyday dependency policy

## Product rule

Allinmyday application runtime code must not depend on third-party Dart/Flutter application packages, copied UI libraries, CDN-hosted runtime libraries, external visual assets, or external application services unless explicitly approved by the product owner.

## Current trial build

The trial APK intentionally uses `lib/trial_main.dart`, which imports only Flutter's framework package and no third-party runtime package.

The previous runtime packages have been removed from `pubspec.yaml` for the trial target. The older feature code remains in the repository so it can be migrated rather than silently discarded.

## Rebuild plan

1. Stabilize the dependency-free trial APK.
2. Audit each old feature for external package imports.
3. Replace required capabilities with Allinmyday-owned implementations or Android platform APIs where appropriate.
4. Reintroduce each feature only after its replacement passes build and functional checks.
5. Keep the 3D renderer free of Three.js, CDN dependencies, and copied assets.

## Build tooling clarification

Flutter, Android SDK, Java, Gradle, and GitHub Actions are build infrastructure rather than Allinmyday application features. If the product requirement is interpreted as literally zero external software even for build infrastructure, the project must be migrated from Flutter to a fully native Android build. That is a separate migration and is not mixed into the trial stabilization step.
