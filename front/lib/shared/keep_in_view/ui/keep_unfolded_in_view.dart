import 'package:flutter/widgets.dart';

/// Keeps the top of [child] on screen at the moment it becomes unfolded.
///
/// In a group where unfolding one item folds another, the item folded above
/// shrinks and can push the newly unfolded one above the visible area. When
/// that happens, the nearest scrollable is moved back to the top of the
/// item. An item whose top is already on screen is left where it is.
class LangwijKeepUnfoldedInView extends StatefulWidget {
  const LangwijKeepUnfoldedInView({
    super.key,
    required this.isUnfolded,
    required this.child,
  });

  final bool isUnfolded;
  final Widget child;

  @override
  State<LangwijKeepUnfoldedInView> createState() =>
      _LangwijKeepUnfoldedInViewState();
}

class _LangwijKeepUnfoldedInViewState
    extends State<LangwijKeepUnfoldedInView> {
  @override
  void didUpdateWidget(LangwijKeepUnfoldedInView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasJustBeenUnfolded = widget.isUnfolded && !oldWidget.isUnfolded;
    if (!hasJustBeenUnfolded) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollTopIntoViewWhenAboveVisibleArea();
    });
  }

  void _scrollTopIntoViewWhenAboveVisibleArea() {
    Scrollable.ensureVisible(
      context,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
