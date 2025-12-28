import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static Analytics? _instance;

  Analytics._();
  static Analytics get instance => _instance ??= Analytics._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
