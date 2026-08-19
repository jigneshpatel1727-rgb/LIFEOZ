import 'iamyansi_event_bus.dart';

/// Publishes normalized results back to the app after an approved executor
/// completes. The UI can subscribe without knowing executor implementation.
class IamyansiResultBus {
  final IamyansiEventBus events;

  const IamyansiResultBus({required this.events});

  void success({required String capability, String message = ''}) {
    events.publish(type: 'action.completed', data: {
      'capability': capability,
      'success': true,
      'message': message,
    });
  }

  void failure({required String capability, required String message}) {
    events.publish(type: 'action.failed', data: {
      'capability': capability,
      'success': false,
      'message': message,
    });
  }
}
