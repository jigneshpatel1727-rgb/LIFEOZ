/// Selects a low-noise moment for proactive Yansi communication.
class YansiProactiveTimingEngine {
  const YansiProactiveTimingEngine();

  String choose({
    required String timing,
    required bool userActive,
    required bool critical,
  }) {
    if (critical) return 'immediate';
    if (!userActive) return timing == 'now' ? 'ambient_later' : 'wait';
    if (timing == 'later' || timing == 'next_active_period') return 'wait';
    return 'surface_now';
  }
}
