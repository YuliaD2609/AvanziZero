import 'package:flutter/material.dart';
import 'dart:async';

extension SmartSnackBar on ScaffoldMessengerState {
  void showSmartSnackBar(SnackBar original) {
    Timer? timer;

    final smartSnackBar = SnackBar(
      content: StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              timer?.cancel();
              timer = Timer(const Duration(seconds: 3), () {
                hideCurrentSnackBar();
              });
            },
            child: original.content,
          );
        },
      ),
      backgroundColor: original.backgroundColor,
      elevation: original.elevation,
      margin: original.margin,
      padding: original.padding,
      width: original.width,
      shape: original.shape,
      behavior: original.behavior,
      action: original.action,
      duration: const Duration(days: 365),
      animation: original.animation,
      onVisible: () {
        timer?.cancel();
        timer = Timer(const Duration(seconds: 3), () {
          hideCurrentSnackBar();
        });
        original.onVisible?.call();
      },
    );

    showSnackBar(smartSnackBar);
  }
}
