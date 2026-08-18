import 'package:shared_preferences/shared_preferences.dart';

/// Central permission policy for iAmYansi capabilities.
///
/// Capabilities are opt-in and stored locally. This keeps the agent from
/// silently performing sensitive actions and gives the UI one place to ask
/// for permission before adding future executors.
class IamyansiCapabilityPolicy {
  static const _prefix = 'iamyansi_capability_';

  final SharedPreferences prefs;

  const IamyansiCapabilityPolicy({required this.prefs});

  bool enabled(IamyansiCapability capability) =>
      prefs.getBool('$_prefix${capability.name}') ?? false;

  Future<void> setEnabled(IamyansiCapability capability, bool value) =>
      prefs.setBool('$_prefix${capability.name}', value);

  bool canExecute(IamyansiCapability capability) => enabled(capability);

  /// Actions that can affect money, external communication, deletion or
  /// device state must still be confirmed by the user at execution time.
  bool requiresConfirmation(IamyansiCapability capability) => switch (capability) {
        IamyansiCapability.expenseWrite => false,
        IamyansiCapability.taskWrite => false,
        IamyansiCapability.shoppingWrite => false,
        IamyansiCapability.calendarWrite => false,
        IamyansiCapability.diaryWrite => false,
        IamyansiCapability.webResearch => false,
        IamyansiCapability.voiceTranscription => false,
        IamyansiCapability.notificationRead => true,
        IamyansiCapability.investmentAction => true,
        IamyansiCapability.externalMessage => true,
        IamyansiCapability.deleteData => true,
        IamyansiCapability.deviceControl => true,
        IamyansiCapability.backgroundListening => true,
      };
}

enum IamyansiCapability {
  expenseWrite,
  taskWrite,
  shoppingWrite,
  calendarWrite,
  diaryWrite,
  webResearch,
  voiceTranscription,
  notificationRead,
  investmentAction,
  externalMessage,
  deleteData,
  deviceControl,
  backgroundListening,
}
