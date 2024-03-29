import 'package:latlong2/latlong.dart';

class SimpleAddress {
  final String label;
  final LatLng position;
  SimpleAddress({
    required this.label,
    required this.position,
  });

  factory SimpleAddress.fromCurrentPosition(LatLng position) {
    return SimpleAddress(
      label: 'La tua posizione',
      position: position,
    );
  }

  String get toQueryPlace =>
      '$label::${position.latitude},${position.longitude}';

  @override
  String toString() => label;
}

class AddressWithDetails extends SimpleAddress {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String houseNumber;
  final String province;
  double distanceInKm;
  AddressWithDetails({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.houseNumber,
    required super.position,
    required super.label,
    required this.province,
    required this.distanceInKm,
  });

  bool get isValid =>
      street.isNotEmpty &&
      city.isNotEmpty &&
      state.isNotEmpty &&
      province.isNotEmpty;
  factory AddressWithDetails.empty() {
    return AddressWithDetails(
      distanceInKm: 0.0,
      province: '',
      label: '',
      street: '',
      city: '',
      state: '',
      postalCode: '',
      houseNumber: '',
      position: const LatLng(0, 0),
    );
  }
  factory AddressWithDetails.fromJson(Map<String, dynamic> json) {
    return AddressWithDetails(
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
      province: json['properties']['region_a'] ?? '',
      distanceInKm: json['properties']['distance']?.toDouble() ?? 0.0,
    );
  }

  String get distanceString {
    if (distanceInKm < 1.0) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  /* @override
  String toString() {
    return toDetailedString(
      showCity: true,
      showStreet: true,
      showPostalCode: true,
      showHouseNumber: true,
      showProvince: true,
      showState: false,
    );
  } */

  String toDetailedString({
    bool showStreet = true,
    bool showCity = false,
    bool showState = false,
    bool showPostalCode = false,
    bool showHouseNumber = false,
    bool showProvince = false,
  }) {
    String result = '';
    if (showStreet) {
      result = street;
    }
    if (showHouseNumber && houseNumber.isNotEmpty) {
      result += '${result.isNotEmpty ? ' ' : ''}$houseNumber';
    }
    if (showPostalCode && postalCode.isNotEmpty) {
      result += '${result.isNotEmpty ? ', ' : ''}$postalCode';
    }
    if (showCity) {
      result += '${result.isNotEmpty ? ', ' : ''}$city';
    }
    if (showProvince) {
      result += '${result.isNotEmpty ? ', ' : ''}$province';
    }
    if (showState) {
      result += '${result.isNotEmpty ? ', ' : ''}$state';
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddressWithDetails &&
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
