/// Central permission model for LifeOS integrations.
/// UI/platform adapters can map these flags to Android permission APIs.
class YansiPrivacyCenter {
  final bool notifications;
  final bool microphone;
  final bool speechRecognition;
  final bool camera;
  final bool health;
  final bool location;
  final bool webAccess;

  const YansiPrivacyCenter({
    this.notifications = false,
    this.microphone = false,
    this.speechRecognition = false,
    this.camera = false,
    this.health = false,
    this.location = false,
    this.webAccess = false,
  });

  YansiPrivacyCenter copyWith({
    bool? notifications,
    bool? microphone,
    bool? speechRecognition,
    bool? camera,
    bool? health,
    bool? location,
    bool? webAccess,
  }) => YansiPrivacyCenter(
        notifications: notifications ?? this.notifications,
        microphone: microphone ?? this.microphone,
        speechRecognition: speechRecognition ?? this.speechRecognition,
        camera: camera ?? this.camera,
        health: health ?? this.health,
        location: location ?? this.location,
        webAccess: webAccess ?? this.webAccess,
      );

  Map<String, bool> toMap() => {
        'notifications': notifications,
        'microphone': microphone,
        'speechRecognition': speechRecognition,
        'camera': camera,
        'health': health,
        'location': location,
        'webAccess': webAccess,
      };
}
