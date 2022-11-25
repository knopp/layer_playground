import 'package:flutter/material.dart';
import 'package:layer_playground/options.dart';
import 'package:provider/provider.dart';

import 'layers.dart';
import 'preset_list.dart';
import 'layer_list.dart';
import 'layer_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class LayerStack extends StatelessWidget {
  LayerStack({super.key});

  final _stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<LayerManager>();
    Widget stack = Stack(
      key: _stackKey,
      clipBehavior: Clip.none,
      children: manager.layers.map((layer) {
        return Positioned.fromRect(
          key: ValueKey(layer.id),
          rect: layer.position,
          child: layer.type == LayerType.flutter
              ? FlutterLayer(
                  layer: layer,
                  manager: manager,
                )
              : NativeLayer(
                  layer: layer,
                  manager: manager,
                ),
        );
      }).toList(),
    );
    if (manager.showBackground) {
      stack = Container(
        color: Colors.blueGrey.withOpacity(0.5),
        child: stack,
      );
    }
    if (manager.clipMode == ClipMode.rect) {
      stack = ClipRect(child: stack);
    } else if (manager.clipMode == ClipMode.roundedRect) {
      stack = ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: stack,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: stack,
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 13, color: Colors.white),
      child: Material(
        color: Colors.transparent,
        textStyle: const TextStyle(color: Colors.white),
        child: ChangeNotifierProvider(
          create: (context) => LayerManager(),
          builder: (context, _) => Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: LayerStack(),
                    ),
                    SizedBox(
                      width: 250,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Color.fromARGB(255, 110, 110, 110))),
                          color: Color.fromARGB(200, 30, 30, 30),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: const [
                            PresetList(),
                            Expanded(child: LayerList()),
                            Options(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
