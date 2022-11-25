import 'package:flutter/material.dart';
import 'package:layer_playground/custom_button.dart';

class Simplebutton extends StatelessWidget {
  const Simplebutton({
    super.key,
    required this.child,
    required this.onPressed,
    this.selected = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: selected ? null : onPressed,
      builder: _builder,
      child: child,
    );
  }

  Widget _builder(BuildContext context, ButtonState state, Widget? child) {
    return IconTheme(
      data: const IconThemeData(color: Colors.white, size: 20),
      child: Container(
        decoration: BoxDecoration(
          color: selected || state.pressed ? Colors.blue : Colors.transparent,
          border: Border.all(
              color: Colors.blue.withOpacity(
                  state.pressed || state.hovered || state.focused ? 1.0 : 0.7)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
            widthFactor: 1.0,
            heightFactor: 1.0,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
