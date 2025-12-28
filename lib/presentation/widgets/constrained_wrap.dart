import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConstrainedWrap extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  const ConstrainedWrap({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? (kIsWeb ? 564 : 320),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}
