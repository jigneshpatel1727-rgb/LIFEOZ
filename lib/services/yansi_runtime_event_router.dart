/// Routes Yansi runtime events to the appropriate lifecycle state.
class YansiRuntimeEventRouter {
  const YansiRuntimeEventRouter();

  String route(String event) {
    switch (event) {
      case 'user_voice_started':
      case 'wake_word_detected':
        return 'listening';
      case 'input_received':
      case 'context_changed':
        return 'thinking';
      case 'action_approved':
        return 'acting';
      case 'response_ready':
        return 'speaking';
      case 'completed':
      case 'cancelled':
      case 'quiet_mode':
        return 'idle';
      default:
        return 'idle';
    }
  }

  Map<String, dynamic> resolve(String event) {
    final state = route(event);
    return {
      'event': event,
      'nextState': state,
      'recognized': state != 'idle' || event == 'completed' || event == 'cancelled' || event == 'quiet_mode',
    };
  }
}
