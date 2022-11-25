import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'buttons.dart';
import 'layer_manager.dart';

class PresetList extends StatelessWidget {
  const PresetList({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<LayerManager>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: manager.presets.length,
          itemBuilder: (context, index) {
            final preset = manager.presets[index];
            return GestureDetector(
              onTapDown: (_) {
                manager.selectPreset(preset);
              },
              child: Container(
                color: manager.isPresetSelected(preset)
                    ? Colors.blue.withOpacity(0.3)
                    : Colors.transparent,
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  Expanded(
                    child: Text('Preset #${preset.id}'),
                  ),
                  Simplebutton(
                    child: const Icon(Icons.delete),
                    onPressed: () {
                      manager.removePreset(preset);
                    },
                  ),
                ]),
              ),
            );
          },
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.3))),
          ),
          child: Simplebutton(
            child: const Text('Add preset'),
            onPressed: () {
              manager.addPreset();
            },
          ),
        ),
      ],
    );
  }
}
