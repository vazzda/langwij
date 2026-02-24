import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srpski_card/app/theme/app_themes.dart';
import 'package:srpski_card/shared/ui/buttons/project_button_group.dart';
import 'package:srpski_card/shared/ui/buttons/project_button_styles.dart' show ButtonSize;

/// Mode for the slider input control
enum SliderInputMode { counter }

/// Zone configuration for non-linear slider behavior
class SliderZoneConfig {
  final int endValue;
  final double portion;
  final String label;
  final int increment;
  final int step;

  const SliderZoneConfig({
    required this.endValue,
    required this.portion,
    required this.label,
    this.increment = 1,
    this.step = 1,
  });
}

const List<SliderZoneConfig> defaultCounterZones = [
  SliderZoneConfig(endValue: 10, portion: 0.25, label: '0-10', increment: 1, step: 1),
  SliderZoneConfig(endValue: 100, portion: 0.25, label: '11-100', increment: 1, step: 5),
  SliderZoneConfig(endValue: 1000, portion: 0.25, label: '101-1k', increment: 10, step: 50),
  SliderZoneConfig(endValue: 10000, portion: 0.25, label: '1k+', increment: 100, step: 500),
];

List<SliderZoneConfig> counterZonesForTarget(int? targetOrLimit) {
  if (targetOrLimit == null || targetOrLimit <= 0) return defaultCounterZones;

  final ceiling = targetOrLimit * 3;
  int zoneCount = defaultCounterZones.length;
  for (int i = 0; i < defaultCounterZones.length; i++) {
    if (ceiling <= defaultCounterZones[i].endValue) {
      zoneCount = i + 1;
      break;
    }
  }

  final portion = 1.0 / zoneCount;
  return List.generate(zoneCount, (i) {
    final zone = defaultCounterZones[i];
    final isLast = i == zoneCount - 1;
    return SliderZoneConfig(
      endValue: zone.endValue,
      portion: isLast ? 1.0 - portion * i : portion,
      label: zone.label,
      increment: zone.increment,
      step: zone.step,
    );
  });
}

class ProjectSliderInput extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int>? onChanged;
  final SliderInputMode mode;
  final String? label;
  final bool zoned;
  final List<SliderZoneConfig>? zones;
  final bool showButtons;
  final bool showInput;
  final int step;
  final String? inputSuffix;
  final bool expandedButtons;

  const ProjectSliderInput({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.onChanged,
    this.mode = SliderInputMode.counter,
    this.label,
    this.zoned = false,
    this.zones,
    this.showButtons = false,
    this.showInput = true,
    this.step = 1,
    this.inputSuffix,
    this.expandedButtons = false,
  });

  @override
  State<ProjectSliderInput> createState() => _ProjectSliderInputState();
}

class _ProjectSliderInputState extends State<ProjectSliderInput> {
  late TextEditingController _counterController;

  bool get _isZoned => widget.zoned;
  List<SliderZoneConfig> get _zones => widget.zones ?? defaultCounterZones;

  @override
  void initState() {
    super.initState();
    _counterController = TextEditingController();
    _updateControllersFromValue(widget.value);
  }

  @override
  void didUpdateWidget(ProjectSliderInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateControllersFromValue(widget.value);
    }
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  void _updateControllersFromValue(int value) {
    _counterController.text = value.toString();
  }

  int _getValueFromControllers() {
    return int.tryParse(_counterController.text) ?? widget.min;
  }

  int _positionToValue(double position) {
    if (!_isZoned) {
      final raw = widget.min + position * (widget.max - widget.min);
      if (widget.step > 1) {
        return ((raw / widget.step).round() * widget.step).clamp(widget.min, widget.max);
      }
      return raw.round();
    }

    double accumulatedPortion = 0;
    int previousEndValue = widget.min;

    for (final zone in _zones) {
      final zoneEnd = accumulatedPortion + zone.portion;
      if (position <= zoneEnd) {
        final positionInZone = (position - accumulatedPortion) / zone.portion;
        final zoneStartValue = previousEndValue;
        final zoneEndValue = math.min(zone.endValue, widget.max);
        final rawValue = zoneStartValue + positionInZone * (zoneEndValue - zoneStartValue);
        final steppedValue = (rawValue / zone.step).round() * zone.step;
        return steppedValue.clamp(zoneStartValue, zoneEndValue);
      }
      accumulatedPortion = zoneEnd;
      previousEndValue = zone.endValue;
    }

    return widget.max;
  }

  double _valueToPosition(int value) {
    if (!_isZoned) {
      if (widget.max == widget.min) return 0;
      return (value - widget.min) / (widget.max - widget.min);
    }

    double accumulatedPortion = 0;
    int previousEndValue = widget.min;

    for (final zone in _zones) {
      final zoneStartValue = previousEndValue;
      final zoneEndValue = math.min(zone.endValue, widget.max);

      if (value < zoneEndValue) {
        final valueInZone = (value - zoneStartValue) / (zoneEndValue - zoneStartValue);
        return accumulatedPortion + valueInZone * zone.portion;
      }

      accumulatedPortion += zone.portion;
      previousEndValue = zone.endValue;
    }

    return 1.0;
  }

  void _handleSliderChange(double position) {
    final newValue = _positionToValue(position).clamp(widget.min, widget.max);
    _updateControllersFromValue(newValue);
    widget.onChanged?.call(newValue);
  }

  void _handleInputChange() {
    final newValue = math.max(widget.min, _getValueFromControllers());
    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppFontStyles.textFormLabel.copyWith(color: AppThemes.of(context).textPrimary),
          ),
          const SizedBox(height: 8),
        ],
        _buildSlider(context),
        if (_isZoned)
          SizedBox(
            height: 0,
            child: OverflowBox(
              maxHeight: 20,
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: _buildZoneLabels(context),
                ),
              ),
            ),
          ),
        if (widget.showInput) ...[
          const SizedBox(height: 4),
          _buildCounterInput(context),
          if (widget.showButtons) ...[
            const SizedBox(height: 4),
            _buildZoneButtons(context),
          ],
        ],
      ],
    );
  }

  Widget _buildCounterInput(BuildContext context) {
    final theme = AppThemes.of(context);
    final hasSuffix = widget.inputSuffix != null;

    return TextField(
      controller: _counterController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: hasSuffix ? TextAlign.center : TextAlign.start,
      style: AppFontStyles.textControlInput.copyWith(color: theme.controlForeground),
      decoration: InputDecoration(
        suffixText: widget.inputSuffix,
        suffixStyle: hasSuffix
            ? AppFontStyles.textControlHint.copyWith(color: theme.textSecondary)
            : null,
        filled: true,
        fillColor: theme.controlBackground,
        contentPadding: EdgeInsets.symmetric(
          horizontal: hasSuffix ? 8 : 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.controlBorderRadius),
          borderSide: BorderSide(color: theme.controlBorder, width: theme.controlBorderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.controlBorderRadius),
          borderSide: BorderSide(color: theme.controlBorder, width: theme.controlBorderWidth),
        ),
      ),
      onChanged: (_) => _handleInputChange(),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final theme = AppThemes.of(context);
    final position = _valueToPosition(widget.value);

    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: theme.controlBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: theme.controlAccentBackground,
              inactiveTrackColor: theme.controlBorder,
              thumbColor: theme.controlAccentBackground,
              overlayColor: theme.controlAccentBackground.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 18,
                elevation: 0,
                pressedElevation: 0,
              ),
              trackShape: _ZonedSliderTrackShape(
                zones: _isZoned ? _zones : const [],
                zoneMarkerColor: theme.textSecondary,
                activeColor: theme.controlAccentBackground,
                inactiveColor: theme.controlBorder,
              ),
            ),
            child: Slider(
              value: position.clamp(0.0, 1.0),
              min: 0.0,
              max: 1.0,
              onChanged: widget.onChanged != null ? _handleSliderChange : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneLabels(BuildContext context) {
    final theme = AppThemes.of(context);

    return Row(
      children: List.generate(_zones.length, (index) {
        final zone = _zones[index];
        return Expanded(
          flex: (zone.portion * 100).round(),
          child: Text(
            zone.label.toUpperCase(),
            style: AppFontStyles.textControlHint.copyWith(
              color: theme.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }),
    );
  }

  Widget _buildZoneButtons(BuildContext context) {
    if (widget.zoned) {
      return Row(
        children: List.generate(_zones.length, (index) {
          final zone = _zones[index];
          final isFirst = index == 0;
          final isLast = index == _zones.length - 1;

          EdgeInsets padding;
          if (isFirst) {
            padding = const EdgeInsets.only(right: 4);
          } else if (isLast) {
            padding = const EdgeInsets.only(left: 4);
          } else {
            padding = const EdgeInsets.symmetric(horizontal: 4);
          }

          return Expanded(
            flex: (zone.portion * 100).round(),
            child: Padding(
              padding: padding,
              child: _buildButtonGroup(context, zone.increment, expanded: true),
            ),
          );
        }),
      );
    } else {
      if (widget.expandedButtons) {
        return _buildButtonGroup(context, 1, expanded: true);
      }
      return Center(
        child: _buildButtonGroup(context, 1, expanded: false),
      );
    }
  }

  Widget _buildButtonGroup(BuildContext context, int increment, {bool expanded = false}) {
    final canDecrement = widget.value > widget.min;

    return ProjectButtonGroup(
      size: ButtonSize.small,
      expanded: expanded,
      items: [
        ProjectButtonGroupItem(
          icon: Icons.remove,
          onPressed: canDecrement && widget.onChanged != null
              ? () => widget.onChanged!(math.max(widget.min, widget.value - increment))
              : null,
        ),
        ProjectButtonGroupItem(
          icon: Icons.add,
          onPressed: widget.onChanged != null
              ? () => widget.onChanged!(widget.value + increment)
              : null,
        ),
      ],
    );
  }
}

class _ZonedSliderTrackShape extends SliderTrackShape {
  final List<SliderZoneConfig> zones;
  final Color zoneMarkerColor;
  final Color activeColor;
  final Color inactiveColor;

  const _ZonedSliderTrackShape({
    required this.zones,
    required this.zoneMarkerColor,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackLeft = offset.dx + 18;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width - 36;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );

    final trackHeight = sliderTheme.trackHeight ?? 4;
    final radius = Radius.circular(trackHeight / 2);

    final inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? inactiveColor;
    context.canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), inactivePaint);

    final activeRect = Rect.fromLTRB(rect.left, rect.top, thumbCenter.dx, rect.bottom);
    final activePaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? activeColor;
    context.canvas.drawRRect(RRect.fromRectAndRadius(activeRect, radius), activePaint);

    final markerPaint = Paint()
      ..color = zoneMarkerColor.withValues(alpha: 0.5)
      ..strokeWidth = 2;

    double accumulatedPortion = 0;
    for (int i = 0; i < zones.length - 1; i++) {
      accumulatedPortion += zones[i].portion;
      final markerX = rect.left + rect.width * accumulatedPortion;
      context.canvas.drawLine(
        Offset(markerX, rect.top - 2),
        Offset(markerX, rect.bottom + 2),
        markerPaint,
      );
    }
  }
}
