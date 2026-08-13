import 'package:shared_preferences/shared_preferences.dart';

import 'yansi_web_access_policy.dart';

/// Safe boundary between Yansi's conversation layer and an eventual web
/// search provider.
///
/// This class never performs a network request. It decides whether a request
/// is explicitly user-initiated and permitted, and gives the UI/provider a
/// transparent reason when it is blocked.
class YansiWebRequestGate {
  final YansiWebAccessPolicy policy;

  const YansiWebRequestGate({required this.policy});

  WebRequestDecision evaluate({required String query, required bool userRequested}) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const WebRequestDecision.blocked('There is no web question to search.');
    }
    if (!userRequested) {
      return const WebRequestDecision.blocked(
        'Yansi does not search the web in the background.',
      );
    }
    if (!policy.isEnabled) {
      return const WebRequestDecision.blocked(
        'Web knowledge is off. Enable it in Permissions when you want Yansi to search.',
      );
    }
    if (policy.provider.isEmpty) {
      return const WebRequestDecision.blocked(
        'Web access is enabled, but no approved search provider is configured.',
      );
    }
    return WebRequestDecision.allowed(
      provider: policy.provider,
      query: normalized,
    );
  }

  Future<void> recordSource(String source) => policy.recordApprovedSource(source);
}

class WebRequestDecision {
  final bool allowed;
  final String message;
  final String? provider;
  final String? query;

  const WebRequestDecision._({
    required this.allowed,
    required this.message,
    this.provider,
    this.query,
  });

  const WebRequestDecision.blocked(String reason)
      : this._(allowed: false, message: reason);

  const WebRequestDecision.allowed({required String provider, required String query})
      : this._(
          allowed: true,
          message: 'Approved web lookup may proceed.',
          provider: provider,
          query: query,
        );

  Map<String, dynamic> toMap() => {
        'allowed': allowed,
        'message': message,
        'provider': provider,
        'queryPresent': query?.isNotEmpty == true,
      };
}

/// Convenience factory for callers that already own SharedPreferences.
YansiWebRequestGate yansiWebRequestGate(SharedPreferences prefs) =>
    YansiWebRequestGate(policy: YansiWebAccessPolicy(prefs: prefs));
