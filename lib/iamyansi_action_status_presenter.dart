import 'iamyansi_action_dispatcher_status.dart';

/// Converts internal Iamyansi action states into short ambient messages.
/// These strings are intentionally UI-neutral so they can drive voice,
/// subtle HUD text, or the future realtime 3D Yansi presence.
class IamyansiActionStatusPresenter {
  const IamyansiActionStatusPresenter();

  String messageFor(IamyansiActionStatus status) {
    switch (status.stage) {
      case IamyansiActionStage.idle:
        return '';
      case IamyansiActionStage.understanding:
        return 'Understanding.';
      case IamyansiActionStage.awaitingConfirmation:
        return status.message.isEmpty ? 'I need your confirmation.' : status.message;
      case IamyansiActionStage.executing:
        return 'Working on it.';
      case IamyansiActionStage.completed:
        return status.message.isEmpty ? 'Done.' : status.message;
      case IamyansiActionStage.failed:
        return status.message.isEmpty ? 'I could not complete that.' : status.message;
    }
  }
}
