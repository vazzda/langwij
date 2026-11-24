import 'package:flessel/flessel.dart';
import 'package:flutter/widgets.dart';
import 'package:langwij/l10n/app_localizations.dart';

/// Builds the password-gate configuration that unlocks the developer section.
class DeveloperGateConfigBuilder {
  const DeveloperGateConfigBuilder._();

  static const String _developerAccessPasswordHash =
      '4ce16e094c68e844b911b1b2e621a3249ccd2d138ed2580cef859ccce932be23';

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
