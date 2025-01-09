import 'package:flutter/material.dart';

extension MyContext on BuildContext {
  Future<T?> showSheet<T>(Widget child, {double? height}) {
    height ??=
        MediaQuery.sizeOf(this).height - MediaQuery.of(this).padding.top - 16;
    return showModalBottomSheet<T>(
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints.expand(height: height),
      builder: (context) {
        return SizedBox(
          height: height,
          child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: child),
        );
      },
      context: this,
    );
  }
}
