import 'dart:async';

/// Internal event bus for connecting Iamyansi to LifeOS features without
/// coupling the AI layer to individual screens.
class IamyansiEventBus {
  final StreamController<IamyansiEvent> _controller =
      StreamController<IamyansiEvent>.broadcast();

  Stream<IamyansiEvent> get events => _controller.stream;

  void publish({required String type, Map<String, dynamic> data = const {}}) {
    if (_controller.isClosed) return;
    _controller.add(IamyansiEvent(type: type, data: Map.unmodifiable(data)));
  }

  Future<void> dispose() => _controller.close();
}

class IamyansiEvent {
  final String type;
  final Map<String, dynamic> data;

  const IamyansiEvent({required this.type, required this.data});
}
