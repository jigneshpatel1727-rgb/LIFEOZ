/// Controls when Yansi should speak or remain ambient.
class YansiResponseCadenceEngine {
  const YansiResponseCadenceEngine();

  Map<String, dynamic> decide({
    required Map<String, dynamic> responsePlan,
    required bool quietHours,
    required bool recentlySpoke,
  }) {
    if (quietHours || recentlySpoke) {
      return {
        'speak': false,
        'channel': 'ambient_signal',
        'reason': quietHours ? 'quiet_hours' : 'recent_response',
      };
    }

    return {
      'speak': responsePlan['speak'] == true,
      'channel': responsePlan['channel'] ?? 'none',
      'reason': 'cadence_allowed',
    };
  }
}
