import 'dart:ui';

import 'package:flessel/flessel.dart' show FlesselDevGate;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DevSectionGateNotifierService extends Notifier<bool> {
  VoidCallback? _listener;

  @override
  bool build() {
    _listener = () {
      state = FlesselDevGate.enabled.value;
    };
    FlesselDevGate.enabled.addListener(_listener!);
    ref.onDispose(() {
      if (_listener != null) {
        FlesselDevGate.enabled.removeListener(_listener!);
      }
    });
    return FlesselDevGate.enabled.value;
  }
}
