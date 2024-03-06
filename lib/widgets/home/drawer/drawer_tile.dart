import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final String? heroTag;
  const DrawerTile({super.key, required this.title, this.onTap, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return heroTag != null
        ? Hero(
            tag: heroTag!,
            flightShuttleBuilder: ((flightContext, animation, flightDirection,
                    fromHeroContext, toHeroContext) =>
                Material(
                  type: MaterialType.transparency,
                  child: toHeroContext.widget,
                )),
            child: _listTile(),
          )
        : _listTile();
  }

  Widget _listTile() {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }
}
