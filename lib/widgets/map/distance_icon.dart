import 'package:flutter/material.dart';
import 'package:torino_mobility/models/map/address.dart';

class DistanceWidget extends StatelessWidget {
  final AddressWithDetails address;
  final bool showIcon;
  final double width;
  const DistanceWidget(
      {super.key,
      required this.address,
      this.showIcon = true,
      this.width = 40});

  @override
  Widget build(BuildContext context) {
    //print(address.distanceInKm);
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) const Icon(Icons.location_on),
          Text(
            address.distanceString,
            style: const TextStyle(letterSpacing: -0.5),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
