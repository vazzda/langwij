import 'package:flessel/flessel.dart';
import 'package:flutter/widgets.dart';
import 'package:langwij/l10n/app_localizations.dart';

/// Builds the password-gate configuration that unlocks the developer section.
class DeveloperGateConfigBuilder {
  const DeveloperGateConfigBuilder._();

  static const String _developerAccessPasswordHash =
      '875dec89dd3b2300db839f43cb4b8d2b6b316cf88262b6e5bbebaa66a73d6ed8';

  static FlesselDevGateConfig buildForContext(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FlesselDevGateConfig(
      passwordHashes: [_developerAccessPasswordHash],
      title: l10n.dev_enterPassword,
      unlockLabel: l10n.dev_unlock,
      cancelLabel: l10n.cancel,
      errorMessage: l10n.dev_wrongPassword,
    );
  }
}
