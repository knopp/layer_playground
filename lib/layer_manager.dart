import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LayerType { flutter, native }

class Layer {
  final int id;
  final LayerType type;

  Rect get position => _position;

  Rect _position = Rect.zero;

  bool get visible => _visible;

  bool _visible = true;

  Layer({
    required this.id,
    required this.type,
  });

  dynamic serialize() => {
        'id': id,
        'type': type.name,
        'visible': visible,
        'position': {
          'left': position.left,
          'top': position.top,
          'right': position.right,
          'bottom': position.bottom,
        },
      };

  static Layer deserialize(dynamic data) {
    final map = data as Map;
    return Layer(
      id: map['id'],
      type: LayerType.values.firstWhere((e) => e.name == map['type']),
    )
      .._visible = map['visible'] ?? true
      .._position = Rect.fromLTRB(
        map['position']['left'],
        map['position']['top'],
        map['position']['right'],
        map['position']['bottom'],
      );
  }
}

class Preset {
  final int id;

  Preset(this.id);

  final List<Layer> _layers = [];

  dynamic serialize() => {
        'id': id,
        'layers': _layers.map((e) => e.serialize()).toList(),
      };

  static Preset deserialize(dynamic data) {
    final map = data as Map;
    final layers = map['layers'] as List;
    return Preset(map['id'])
      .._layers.addAll(
        layers.map((e) => Layer.deserialize(e)).toList(),
      );
  }
}

enum ClipMode {
  none,
  rect,
  roundedRect,
}

class LayerManager extends ChangeNotifier {
  LayerManager() {
    _presets.add(Preset(0));
    _currentPreset = _presets.first;
    _restore();
  }

  List<Preset> get presets => List.unmodifiable(_presets);

  void selectPreset(Preset preset) {
    if (_currentPreset != preset) {
      _currentPreset = preset;
      _selectedLayer = null;
      notifyListeners();
    }
  }

  void addPreset() {
    _presets.add(Preset(_nextPresetId()));
    notifyListeners();
  }

  void removePreset(Preset preset) {
    var index = _presets.indexOf(preset);
    _presets.remove(preset);
    if (_presets.isEmpty) {
      _presets.add(Preset(_nextPresetId()));
    }
    if (index < 0 || index >= _presets.length) {
      index = _presets.length - 1;
    }
    _currentPreset = _presets[index];
    notifyListeners();
  }

  bool isPresetSelected(Preset preset) {
    return _currentPreset == preset;
  }

  void setLayerVisible(Layer layer, bool visible) {
    layer._visible = visible;
    notifyListeners();
  }

  void _addLayer(Layer layer) {
    _layers.add(layer);
    notifyListeners();
  }

  void selectLayer(Layer layer) {
    _selectedLayer = layer;
    notifyListeners();
  }

  void moveLayer(Layer layer, Offset offset) {
    layer._position = layer._position.shift(offset);
    notifyListeners();
  }

  void reoderLayer(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      --newIndex;
    }
    final layer = _layers.removeAt(oldIndex);
    _layers.insert(newIndex, layer);
    notifyListeners();
  }

  void resizeLayer(Layer layer, Offset offset) {
    layer._position = Rect.fromPoints(
      layer._position.topLeft,
      layer._position.bottomRight + offset,
    );
    notifyListeners();
  }

  void removeLayer(Layer layer) {
    _layers.remove(layer);
    notifyListeners();
  }

  void addFlutterLayer() {
    final layer = Layer(type: LayerType.flutter, id: _nextLayerId());
    layer._position = _nextPosition(layer.id);
    _addLayer(layer);
  }

  void addNativeLayer() {
    final layer = Layer(type: LayerType.native, id: _nextLayerId());
    layer._position = _nextPosition(layer.id);
    _addLayer(layer);
  }

  Rect _nextPosition(int layerId) {
    final offset = (layerId % 10) * 50.0;
    return Rect.fromLTWH(offset, offset, 200, 200);
  }

  bool isLayerSelected(Layer layer) {
    return _selectedLayer == layer;
  }

  Layer? _layerForId(int id) {
    for (final preset in _presets) {
      final res = preset._layers.firstWhereOrNull((layer) => layer.id == id);
      if (res != null) {
        return res;
      }
    }
    return null;
  }

  int _nextPresetId() {
    int id = 0;
    while (_presets.firstWhereOrNull((p) => p.id == id) != null) {
      ++id;
    }
    return id;
  }

  int _nextLayerId() {
    int id = 0;
    while (_layerForId(id) != null) {
      ++id;
    }
    return id;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _save);
  }

  Timer? _saveTimer;

  void _save() async {
    final state = {
      'presets': _presets.map((e) => e.serialize()).toList(),
      'currentPreset': _currentPreset?.id,
      'clipMode': _clipMode.name,
      'showBackground': _showBackground,
    };
    final json = jsonEncode(state);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('state', json);
  }

  void _restore() async {
    final preferences = await SharedPreferences.getInstance();
    final state = preferences.getString('state');
    if (state != null) {
      final map = jsonDecode(state) as Map;
      _presets.clear();
      _presets
          .addAll((map['presets'] as List).map((e) => Preset.deserialize(e)));
      if (_presets.isEmpty) {
        _presets.add(Preset(_nextPresetId()));
      }
      final currentPresetId = map['currentPreset'];
      _currentPreset =
          _presets.firstWhereOrNull((e) => e.id == currentPresetId);
      _currentPreset ??= presets[0];

      _clipMode = ClipMode.values.firstWhere(
        (e) => e.name == map['clipMode'],
        orElse: () => ClipMode.none,
      );

      _showBackground = map['showBackground'] ?? true;

      notifyListeners();
    }
  }

  set clipMode(ClipMode value) {
    _clipMode = value;
    notifyListeners();
  }

  ClipMode get clipMode => _clipMode;

  set showBackground(bool value) {
    _showBackground = value;
    notifyListeners();
  }

  bool get showBackground => _showBackground;

  bool _showBackground = true;

  Layer? _selectedLayer;

  List<Layer> get _layers => _currentPreset!._layers;

  List<Layer> get layers => List.unmodifiable(_layers);

  Preset? _currentPreset;

  final List<Preset> _presets = [];

  ClipMode _clipMode = ClipMode.none;
}
