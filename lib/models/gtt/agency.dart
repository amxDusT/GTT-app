class Agency {
  final String gtfsId;
  final String name;
  final String url;
  final String fareUrl;
  final String phone;
  const Agency({
    required this.gtfsId,
    required this.name,
    required this.url,
    required this.fareUrl,
    required this.phone,
  });

  factory Agency.fromJson(Map<String, dynamic> js) {
    return Agency(
      gtfsId: js['gtfsId'],
      name: js['name'],
      url: js['url'],
      fareUrl: js['fareUrl'],
      phone: js['phone'],
    );
  }
  Map<String, dynamic> toMap() => {
        'gtfsId': gtfsId,
        'name': name,
        'url': url,
        'fareUrl': fareUrl,
        'phone': phone,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Agency &&
        other.gtfsId == gtfsId &&
        other.name == name &&
        other.url == url &&
        other.fareUrl == fareUrl &&
        other.phone == phone;
  }

  @override
  int get hashCode => Object.hash(gtfsId, name, url, fareUrl, phone);
}
