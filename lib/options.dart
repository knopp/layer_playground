import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:layer_playground/buttons.dart';
import 'package:provider/provider.dart';

import 'layer_manager.dart';

class Options extends StatelessWidget {
  const Options({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<LayerManager>();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('Clip'),
              Simplebutton(
                selected: manager.clipMode == ClipMode.none,
                onPressed: () {
                  manager.clipMode = ClipMode.none;
                },
                child: const Text('None'),
              ),
              Simplebutton(
                selected: manager.clipMode == ClipMode.rect,
                onPressed: () {
                  manager.clipMode = ClipMode.rect;
                },
                child: const Text('Rect'),
              ),
              Simplebutton(
                selected: manager.clipMode == ClipMode.roundedRect,
                onPressed: () {
                  manager.clipMode = ClipMode.roundedRect;
                },
                child: const Text('Rounded'),
              )
            ].intersperse(const SizedBox(width: 8)).toList(growable: false),
          ),
          Row(
            children: <Widget>[
              const Text('Paint Background'),
              Simplebutton(
                selected: manager.showBackground,
                onPressed: () {
                  manager.showBackground = true;
                },
                child: const Text('Yes'),
              ),
              Simplebutton(
                selected: manager.showBackground == false,
                onPressed: () {
                  manager.showBackground = false;
                },
                child: const Text('No'),
              ),
            ].intersperse(const SizedBox(width: 8)).toList(growable: false),
          )
        ].intersperse(const SizedBox(height: 10)).toList(growable: false),
      ),
    );
  }
}
