import 'package:flutter/material.dart';

import '../../../app/theme/app_themes.dart';

/// Themed bottom sheet wrapper. Applies project styling automatically.
Future<T?> showProjectBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
}) {
  final t = AppThemes.of(context);
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: t.bottomSheetBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(t.bottomSheetBorderRadius),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: EdgeInsets.all(t.bottomSheetPadding),
        child: builder(sheetContext),
      ),
    ),
  );
}
