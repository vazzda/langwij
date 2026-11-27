import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

/// The word of a card as the card's title: its first letter a capital, in
/// the title font.
class TermTitle extends StatelessWidget {
  const TermTitle({super.key, required this.text});

  /// The word as the card holds it; the capital letter is given here.
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);

    return Text(
      _capitalize(text),
      style: FlesselFonts.contentXxxlAccent.copyWith(color: t.fg),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
