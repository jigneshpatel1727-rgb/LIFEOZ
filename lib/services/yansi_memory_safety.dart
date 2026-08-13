import 'lifeos_intelligence_bus.dart';

/// Controls what Yansi may retain from LifeOS activity.
/// Sensitive content is excluded unless the user explicitly enables retention.
class YansiMemorySafety {
  final bool retainVoice;
  final bool retainSensitive;
  const YansiMemorySafety({this.retainVoice = false, this.retainSensitive = false});

  bool shouldRetain(LifeOSSignal signal) {
    if (signal.type == LifeOSSignalType.voice && !retainVoice) return false;
    if (signal.data['sensitive'] == true && !retainSensitive) return false;
    return true;
  }

  Map<String, dynamic> sanitize(LifeOSSignal signal) {
    final data = Map<String, dynamic>.from(signal.data);
    if (!retainSensitive) {
      data.remove('password');
      data.remove('otp');
      data.remove('pin');
      data.remove('bankAccount');
      data.remove('cardNumber');
    }
    if (!retainVoice) data.remove('audioPath');
    return {'type': signal.type.name, 'text': signal.text, 'timestamp': signal.timestamp.toIso8601String(), 'data': data};
  }
}
