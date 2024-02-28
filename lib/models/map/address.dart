import 'package:latlong2/latlong.dart';

class Address {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String houseNumber;
  final LatLng position;
  final String label;
  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.houseNumber,
    required this.position,
    required this.label,
  });

  bool get isValid => street.isNotEmpty && city.isNotEmpty && state.isNotEmpty;
  factory Address.empty() {
    return Address(
      label: '',
      street: '',
      city: '',
      state: '',
      postalCode: '',
      houseNumber: '',
      position: const LatLng(0, 0),
    );
  }
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      position: LatLng(
        json['geometry']['coordinates'][1] ?? '',
        json['geometry']['coordinates'][0] ?? '',
      ),
      street: json['properties']['street'] ?? json['properties']['name'] ?? '',
      houseNumber: json['properties']['housenumber'] ?? '',
      city: (json['properties']?['localadmin'] == 'Turin')
          ? 'Torino'
          : json['properties']['localadmin'] ?? '',
      state: json['properties']['country'] ?? '',
      postalCode: json['properties']['postalcode'] ?? '',
      label: json['properties']['label'] ?? '',
    );
  }

  @override
  String toString() {
    return '$street $houseNumber, $city, $state, $postalCode';
  }

  String toDetailedString(
      {bool showCity = false,
      showState = false,
      showPostalCode = false,
      showHouseNumber = false}) {
    return '$street${showHouseNumber && houseNumber.isNotEmpty ? ' $houseNumber' : ''}${showCity ? ', $city' : ''}${showState ? ', $state' : ''}${showPostalCode && postalCode.isNotEmpty ? ', $postalCode' : ''}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Address &&
        other.street == street &&
        other.city == city &&
        other.state == state &&
        other.postalCode == postalCode &&
        other.houseNumber == houseNumber;
  }

  @override
  int get hashCode =>
      street.hashCode ^
      city.hashCode ^
      state.hashCode ^
      postalCode.hashCode ^
      houseNumber.hashCode;
}
