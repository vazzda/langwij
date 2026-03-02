import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/vessel_themes.dart';

/// Show a themed bottom sheet with consistent styling across the app.
///
/// Uses theme values for:
/// - backgroundColor: bottomSheetBackground
/// - barrierColor: bottomSheetScrimColor
/// - borderRadius: bottomSheetBorderRadius
/// - border: bottomSheetBorderColor, bottomSheetBorderWidth
/// - blurSigma: bottomSheetBlurSigma (0 = no blur, 10+ = strong blur)
///
/// The [builder] receives the BuildContext and should return the sheet content.
/// Default padding (`theme.bottomSheetPadding`) is applied automatically.
/// Pass [padding] to override (e.g. to account for keyboard insets).
Future<T?> showVesselBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  EdgeInsetsGeometry? padding,
  bool isScrollControlled = true,
  bool useDraggableSheet = false,
  double draggableInitialSize = 0.5,
  double draggableMinSize = 0.3,
  double draggableMaxSize = 0.9,
  bool isDismissible = true,
}) {
  final theme = VesselThemes.of(context);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    barrierColor: theme.bottomSheetScrimColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(theme.bottomSheetBorderRadius),
      ),
    ),
    builder: (sheetContext) {
      final effectivePadding =
          padding ?? EdgeInsets.all(theme.bottomSheetPadding);

      Widget applyPadding(Widget child) =>
          Padding(padding: effectivePadding, child: child);

      final content = useDraggableSheet
          ? DraggableScrollableSheet(
              initialChildSize: draggableInitialSize,
              minChildSize: draggableMinSize,
              maxChildSize: draggableMaxSize,
              expand: false,
              builder: (context, scrollController) => SafeArea(
                top: false,
                child: applyPadding(builder(context)),
              ),
            )
          : SafeArea(
              top: false,
              child: applyPadding(builder(sheetContext)),
            );

      return _buildBlurredSheet(
        theme: theme,
        backgroundColor: theme.bottomSheetBackground,
        child: content,
      );
    },
  );
}

/// Helper to build a bottom sheet with optional blur effect.
/// If [theme.bottomSheetBlurSigma] > 0, applies backdrop blur.
Widget _buildBlurredSheet({
  required VesselThemeData theme,
  required Color backgroundColor,
  required Widget child,
}) {
  final borderRadius = BorderRadius.vertical(
    top: Radius.circular(theme.bottomSheetBorderRadius),
  );

  return ClipRRect(
    borderRadius: borderRadius,
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: theme.bottomSheetBlurSigma,
        sigmaY: theme.bottomSheetBlurSigma,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: Border.all(
            color: theme.bottomSheetBorderColor,
            width: theme.bottomSheetBorderWidth,
          ),
        ),
        child: child,
      ),
    ),
  );
}
