import 'iamyansi_action_dispatcher_status.dart';
import 'iamyansi_action_status_presenter.dart';

/// Small UI-neutral state coordinator for the ambient Iamyansi presence.
///
/// The app can subscribe to this state without turning Yansi into a chatbot.
/// Voice/HUD/3D presentation layers can consume the same snapshot.
class IamyansiAmbientState {
  IamyansiAmbientState({IamyansiActionStatus? initialStatus})
      : _status = initialStatus ??
            IamyansiActionStatus(stage: IamyansiActionStage.idle, message: '');

  final IamyansiActionStatusPresenter _presenter =
      const IamyansiActionStatusPresenter();
  IamyansiActionStatus _status;

  IamyansiActionStatus get status => _status;
  String get ambientMessage => _presenter.messageFor(_status);
  bool get isActive => _status.stage != IamyansiActionStage.idle;
  bool get requiresConfirmation =>
      _status.stage == IamyansiActionStage.awaitingConfirmation;

  void update(IamyansiActionStatus next) {
    _status = next;
  }

  void reset() {
    _status = IamyansiActionStatus(
      stage: IamyansiActionStage.idle,
      message: '',
    );
  }
}
