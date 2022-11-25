import 'package:flutter/material.dart' show Colors, Icons, ReorderableListView;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'layer_manager.dart';
import 'buttons.dart';

class LayerList extends StatelessWidget {
  const LayerList({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<LayerManager>();
    return IconTheme(
      data: const IconThemeData(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ReorderableListView.builder(
              onReorder: (oldIndex, newIndex) {
                manager.reoderLayer(oldIndex, newIndex);
              },
              itemCount: manager.layers.length,
              itemBuilder: (context, index) {
                final layer = manager.layers[index];
                return Container(
                  padding: const EdgeInsets.all(8).copyWith(right: 40),
                  key: ValueKey(index),
                  color: manager.isLayerSelected(layer)
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Layer #${layer.id}'),
                            const SizedBox(height: 4),
                            Text(
                              layer.type == LayerType.native
                                  ? 'Native'
                                  : 'Flutter',
                              style: TextStyle(
                                  color: layer.type == LayerType.native
                                      ? Colors.yellow
                                      : Colors.grey,
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Simplebutton(
                        child: const Icon(Icons.delete),
                        onPressed: () {
                          manager.removeLayer(layer);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.3))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Simplebutton(
                  child: const Text('Add Flutter Layer'),
                  onPressed: () {
                    manager.addFlutterLayer();
                  },
                ),
                const SizedBox(height: 6),
                Simplebutton(
                  child: const Text('Add Native Layer'),
                  onPressed: () {
                    manager.addNativeLayer();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
