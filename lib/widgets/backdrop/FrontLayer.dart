import 'package:flutter/material.dart';

class FrontLayer extends StatelessWidget {
  final VoidCallback onTap;

  final Widget child;
  final bool frontLayerVisible;
  const FrontLayer({
    Key? key,
    required this.onTap,
    required this.child,
    required this.frontLayerVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool ignoreTouch = false;
    if (!frontLayerVisible) {
      ignoreTouch = true;
    }
    return Material(
      elevation: 16.0,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28.0)),
      ),
      child: GestureDetector(
        onTap: () {
          if (!frontLayerVisible) {
            onTap();
          }
        },
        child: AbsorbPointer(absorbing: ignoreTouch, child: child),
      ),
    );
  }
}
