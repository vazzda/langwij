import 'package:flutter/material.dart';
import 'package:srpski_card/app/theme/app_themes.dart';

/// Tag color options
/// Each theme defines specific colors for color1-color5
/// "none" represents a transparent tag with just a border
enum TagColor {
  none,
  color1,
  color2,
  color3,
  color4,
  color5,
}

/// Extension methods for TagColor
extension TagColorExtension on TagColor {
  /// Get the display name for UI
  String get displayName {
    switch (this) {
      case TagColor.none:
        return 'No Color';
      case TagColor.color1:
        return 'Blue';
      case TagColor.color2:
        return 'Green';
      case TagColor.color3:
        return 'Purple';
      case TagColor.color4:
        return 'Orange';
      case TagColor.color5:
        return 'Teal';
    }
  }

  /// Get the accent color from theme (for picker/editor controls)
  Color getColor(AppThemeData themeData) {
    switch (this) {
      case TagColor.none:
        return Colors.transparent;
      case TagColor.color1:
        return themeData.tagColor1;
      case TagColor.color2:
        return themeData.tagColor2;
      case TagColor.color3:
        return themeData.tagColor3;
      case TagColor.color4:
        return themeData.tagColor4;
      case TagColor.color5:
        return themeData.tagColor5;
    }
  }

  /// Get the background color for atom tile badges
  Color getBgColor(AppThemeData themeData) {
    switch (this) {
      case TagColor.none:
        return themeData.tagNoneBg;
      case TagColor.color1:
        return themeData.tag1Bg;
      case TagColor.color2:
        return themeData.tag2Bg;
      case TagColor.color3:
        return themeData.tag3Bg;
      case TagColor.color4:
        return themeData.tag4Bg;
      case TagColor.color5:
        return themeData.tag5Bg;
    }
  }

  /// Get the border color for atom tile badges
  Color getBorderColor(AppThemeData themeData) {
    switch (this) {
      case TagColor.none:
        return themeData.tagNoneBorderColor;
      case TagColor.color1:
        return themeData.tag1BorderColor;
      case TagColor.color2:
        return themeData.tag2BorderColor;
      case TagColor.color3:
        return themeData.tag3BorderColor;
      case TagColor.color4:
        return themeData.tag4BorderColor;
      case TagColor.color5:
        return themeData.tag5BorderColor;
    }
  }

  /// Get the text color for atom tile badges
  Color getTextColor(AppThemeData themeData) {
    switch (this) {
      case TagColor.none:
        return themeData.tagNoneTextColor;
      case TagColor.color1:
        return themeData.tag1TextColor;
      case TagColor.color2:
        return themeData.tag2TextColor;
      case TagColor.color3:
        return themeData.tag3TextColor;
      case TagColor.color4:
        return themeData.tag4TextColor;
      case TagColor.color5:
        return themeData.tag5TextColor;
    }
  }

  /// Parse from string (for database storage)
  static TagColor fromString(String value) {
    switch (value) {
      case 'none':
        return TagColor.none;
      case 'color1':
        return TagColor.color1;
      case 'color2':
        return TagColor.color2;
      case 'color3':
        return TagColor.color3;
      case 'color4':
        return TagColor.color4;
      case 'color5':
        return TagColor.color5;
      default:
        return TagColor.none;
    }
  }
}

/// Tag entity
/// Used to categorize items for organization and filtering
class Tag {
  final String id;
  final String name;
  final TagColor color;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
  });

  /// Create a copy with updated values
  Tag copyWith({
    String? id,
    String? name,
    TagColor? color,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.name,
    };
  }

  /// Create from JSON
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: TagColorExtension.fromString(json['color'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag &&
        other.id == id &&
        other.name == name &&
        other.color == color;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ color.hashCode;

  @override
  String toString() => 'Tag(id: $id, name: $name, color: ${color.name})';
}
