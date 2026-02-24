import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';
import 'package:srpski_card/entities/tag/tag.dart';

/// Size variants for TagLabel
enum TagLabelSize {
  icon, // Used in tile displays - 2-letter abbreviation, no icon
  tiny, // Used in list displays - full name, no icon
  regular, // Used in detailed displays - full name with icon
  cluster, // Used in cluster tile badges - full name, single line, clipped overflow
}

/// A tag label widget for displaying tags in displays and reports
///
/// Theme-dependent styling:
/// - Newspaper: white background, tag color border, black text/icon
/// - Contrast: tag color background/border, white text/icon
/// - Colorful: tag color background/border, black text/icon
/// - "no color" tags: transparent background, theme border, theme text
class TagLabel extends StatelessWidget {
  final Tag tag;
  final TagLabelSize size;

  const TagLabel({
    super.key,
    required this.tag,
    this.size = TagLabelSize.regular,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = AppThemes.of(context);

    // Cluster size uses different color system (tile-specific colors)
    if (size == TagLabelSize.cluster) {
      return _buildClusterBadge(themeData);
    }

    final isNoColor = tag.color == TagColor.none;

    // Determine colors using theme-defined tag variables
    final colors = _getColors(themeData, isNoColor);

    // Size-dependent values
    final bool isSmall = size == TagLabelSize.tiny || size == TagLabelSize.icon;
    final padding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 8);
    final showIcon = size == TagLabelSize.regular;

    // Icon color: use border color (same as tag color for colored tags)
    final iconColor = colors.border;

    // Text style: icon and tiny use small bold font, regular uses medium button font
    final textStyle = isSmall
        ? AppFontStyles.textTagIcon.copyWith(color: colors.foreground)
        : AppFontStyles.textButton.copyWith(color: colors.foreground);

    // Display text: icon size uses 2-letter abbreviation, others use full name
    final displayText = size == TagLabelSize.icon
        ? _getAbbreviation(tag.name)
        : tag.name.toUpperCase();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(themeData.tagBorderRadius),
        border: Border.all(
          color: colors.border,
          width: themeData.tagBorderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.label, size: 24.0, color: iconColor),
            const SizedBox(width: 4),
          ],
          Text(displayText, style: textStyle),
        ],
      ),
    );
  }

  /// Build cluster badge - full name, single line, clipped overflow
  /// Uses tile-specific colors from theme (tag*Bg, tag*BorderColor, tag*TextColor)
  Widget _buildClusterBadge(AppThemeData themeData) {
    final bgColor = tag.color.getBgColor(themeData);
    final borderColor = tag.color.getBorderColor(themeData);
    final textColor = tag.color.getTextColor(themeData);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(themeData.badgeBorderRadius),
        border: Border.all(
          color: borderColor,
          width: themeData.badgeBorderWidth,
        ),
      ),
      child: Text(
        tag.name.toUpperCase(),
        style: AppFontStyles.textTagIcon.copyWith(color: textColor, height: 1.0),
        maxLines: 1,
        overflow: TextOverflow.clip,
        softWrap: false,
      ),
    );
  }

  /// Get 2-letter abbreviation from tag name
  /// - One word: first 2 letters (e.g., "Design" -> "DE")
  /// - Two+ words: first letter of first two words (e.g., "Very Urgent" -> "VU")
  String _getAbbreviation(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';

    if (words.length == 1) {
      final word = words[0];
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word.toUpperCase();
    } else {
      final first = words[0].isNotEmpty ? words[0][0] : '';
      final second = words[1].isNotEmpty ? words[1][0] : '';
      return '$first$second'.toUpperCase();
    }
  }

  /// Get colors based on tag color using theme variables
  ({Color background, Color border, Color foreground}) _getColors(
    AppThemeData themeData,
    bool isNoColor,
  ) {
    return (
      background: tag.color.getBgColor(themeData),
      border: tag.color.getBorderColor(themeData),
      foreground: tag.color.getTextColor(themeData),
    );
  }
}
