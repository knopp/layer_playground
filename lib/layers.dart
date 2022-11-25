import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' hide Layer;
import 'package:flutter/services.dart';
import 'package:layer_playground/layer_manager.dart';

class _LayerDrag implements Drag {
  final Layer layer;
  final LayerManager manager;

  _LayerDrag(
    this.layer,
    this.manager,
  );

  @override
  void cancel() {}

  @override
  void end(DragEndDetails details) {}

  @override
  void update(DragUpdateDetails details) {
    manager.moveLayer(layer, details.delta);
  }
}

class NativeLayer extends StatelessWidget {
  const NativeLayer({
    super.key,
    required this.manager,
    required this.layer,
  });

  final LayerManager manager;
  final Layer layer;

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = '@views/simple-box-view-type';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    return LayerDrag(
      layer: layer,
      manager: manager,
      child: IgnorePointer(
        child: UiKitView(
          hitTestBehavior: PlatformViewHitTestBehavior.translucent,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      ),
    );
  }
}

class _LayerResize implements Drag {
  final Layer layer;
  final LayerManager manager;

  _LayerResize(
    this.layer,
    this.manager,
  );

  @override
  void cancel() {}

  @override
  void end(DragEndDetails details) {}

  @override
  void update(DragUpdateDetails details) {
    manager.resizeLayer(layer, details.delta);
  }
}

class FlutterLayer extends StatelessWidget {
  const FlutterLayer({
    super.key,
    required this.manager,
    required this.layer,
  });

  final LayerManager manager;
  final Layer layer;

  @override
  Widget build(BuildContext context) {
    return LayerDrag(
      layer: layer,
      manager: manager,
      child: Stack(
        children: [
          Positioned.fill(
              child: Container(
                  decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Colors.blueGrey.withOpacity(0.95),
          ))),
          const Positioned.fill(child: FlutterLogo()),
          Positioned(
            bottom: 0,
            right: 0,
            child: LayerResize(
              layer: layer,
              manager: manager,
              child: Container(
                width: 10,
                height: 10,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LayerDrag extends StatelessWidget {
  const LayerDrag({
    super.key,
    required this.layer,
    required this.manager,
    required this.child,
  });

  final Layer layer;
  final LayerManager manager;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      hitTestBehavior: HitTestBehavior.opaque,
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          ImmediateMultiDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                  ImmediateMultiDragGestureRecognizer>(
            () => ImmediateMultiDragGestureRecognizer(),
            (instance) {
              instance.onStart = (details) {
                manager.selectLayer(layer);
                return _LayerDrag(layer, manager);
              };
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class LayerResize extends StatelessWidget {
  const LayerResize({
    super.key,
    required this.layer,
    required this.manager,
    required this.child,
  });

  final Layer layer;
  final LayerManager manager;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeDownRight,
      hitTestBehavior: HitTestBehavior.opaque,
      child: RawGestureDetector(
        gestures: {
          ImmediateMultiDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                  ImmediateMultiDragGestureRecognizer>(
            () => ImmediateMultiDragGestureRecognizer(),
            (instance) {
              instance.onStart = (details) {
                return _LayerResize(layer, manager);
              };
            },
          ),
        },
        child: child,
      ),
    );
  }
}
