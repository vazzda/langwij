import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

/// Langwij composite: tappable tile for quiz answer options.
///
/// Wraps [FlesselTile] with centered, bold 20px text. Used by the round
/// screen for both Serbian-shown and English-shown answer branches.
class LangwijAnswerTile extends StatelessWidget {
  const LangwijAnswerTile({
    super.key,
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FlesselTile(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(FlesselLayout.gapS),
        child: Center(
          child: Text(
            label,
            style: FlesselFonts.contentXxlAccent,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
