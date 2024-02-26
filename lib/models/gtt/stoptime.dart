class Stoptime {
  final bool realtime;
  final DateTime realtimeDeparture;
  final DateTime scheduledDeparture;

  const Stoptime(
      {required this.realtime,
      required this.realtimeDeparture,
      required this.scheduledDeparture});

  static DateTime _getDate(int departure) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.add(Duration(seconds: departure));
  }

  factory Stoptime.fromJson(Map<String, dynamic> js) {
    return Stoptime(
      realtime: js['realtime'],
      realtimeDeparture: _getDate(js['realtimeDeparture'] as int),
      scheduledDeparture: _getDate(js['scheduledDeparture'] as int),
    );
  }

  @override
  String toString() {
    return 'Stoptime{realtime: $realtime, realtimeDeparture: $realtimeDeparture, scheduledDeparture: $scheduledDeparture}';
  }
}
