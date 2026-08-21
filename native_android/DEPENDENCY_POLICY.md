# Allinmyday Native Dependency Policy

## Locked rule

The Allinmyday application layer must be built by Allinmyday and Android platform APIs only.

### Prohibited in the application layer
- Flutter or another cross-platform application framework
- Third-party UI kits or component libraries
- Third-party 3D engines
- Three.js or CDN-hosted libraries
- Third-party runtime packages
- Bundled AAR/JAR/native libraries from outside Allinmyday
- Copied templates, icons, images, models or code
- External AI agents or runtime AI SDKs
- External runtime databases/services unless explicitly approved later

### Allowed foundation
- Android platform APIs supplied by the target Android operating system
- Android SDK build tools and JDK tools required to produce an Android APK
- Allinmyday-owned Java source, resources, algorithms, icons, graphics and data structures

### CI clarification
GitHub-hosted CI actions may be used only as build infrastructure. They are not packaged into or executed by the Allinmyday APK and are not application dependencies. The application itself must pass `audit_allinmyday.sh` before a trial build is accepted.

## Acceptance gate
A trial APK is not called GREEN until:
1. the native audit passes;
2. the Android SDK build succeeds;
3. APK signing succeeds;
4. APK signature verification succeeds; and
5. a workflow artifact is produced.
