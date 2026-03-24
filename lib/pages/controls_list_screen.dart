import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../app/layout/vessel_layout.dart';
import '../l10n/app_localizations.dart';
import '../app/theme/vessel_themes.dart';
import '../entities/tag/tag.dart';
import '../shared/ui/buttons/vessel_buttons.dart';
import '../shared/ui/buttons/vessel_button_group.dart';
import '../shared/ui/card/vessel_card.dart';
import '../shared/ui/divider/vessel_divider.dart';
import '../shared/ui/inputs/vessel_date_picker.dart';
import '../shared/ui/inputs/vessel_hour_picker.dart';
import '../shared/ui/inputs/vessel_input_row.dart';
import '../shared/ui/inputs/vessel_input_styles.dart';
import '../shared/ui/inputs/vessel_radio_grid.dart';
import '../shared/ui/inputs/vessel_radio_tile.dart';
import '../shared/ui/inputs/vessel_slider_input.dart';
import '../shared/ui/inputs/vessel_dropdown.dart';
import '../shared/ui/inputs/vessel_text_input.dart';
import '../shared/ui/inputs/vessel_time_slider.dart';
import '../shared/ui/inputs/vessel_toggles.dart';
import '../shared/ui/note/vessel_note.dart';
import '../shared/ui/progress_bar/vessel_progress_bar.dart';
import '../shared/ui/snackbar/vessel_snackbar.dart';
import '../shared/ui/tag/vessel_tag_chip.dart';
import '../shared/ui/tag/vessel_tag_label.dart';
import '../shared/ui/text/vessel_header.dart';
import '../shared/ui/answer_tile/vessel_answer_tile.dart';
import '../shared/ui/tile/vessel_tile.dart';
import '../shared/ui/bottom_sheet/vessel_bottom_sheet.dart';
import '../shared/ui/bottom_sheet/quiz_bottom_sheets.dart';
import '../shared/ui/gap/vessel_gap.dart';
import '../shared/ui/screen_layout/vessel_scaffold.dart';

/// Developer controls list screen - Showcase all UI components
class ControlsListScreen extends StatefulWidget {
  const ControlsListScreen({super.key});

  @override
  State<ControlsListScreen> createState() => _ControlsListScreenState();
}

class _ControlsListScreenState extends State<ControlsListScreen> {
  bool _demoCheckbox = true;
  bool _demoSwitch = true;
  String _radioValue = 'A';
  String _demoGridRadio = 'Time';
  final _textController = TextEditingController();

  // Controllers for ProjectInputRow demo
  final _dayController = TextEditingController();
  final _weekController = TextEditingController();
  final _monthController = TextEditingController();

  // Controllers for ProjectInputRow exclusive demo
  final _dayExclusiveController = TextEditingController();
  final _weekExclusiveController = TextEditingController();
  final _monthExclusiveController = TextEditingController();

  // State for VesselDatePicker demo
  DateTime? _demoStartDate;
  DateTime? _demoEndDate;

  // State for VesselSliderInput demo
  int _demoSliderCounter = 50;
  int _demoSliderCounterZoned = 500;
  int _demoSliderCounterButtons = 250;
  int _demoSliderTime = 90;
  int _demoSliderTimeButtons = 75;

  // State for VesselDropdown demo
  String _demoDropdownValue = 'apple';

  // State for hour picker
  int _selectedHour = 9;

  // State for tag color preview
  TagColor _selectedTagColor = TagColor.color1;

  @override
  void dispose() {
    _textController.dispose();
    _dayController.dispose();
    _weekController.dispose();
    _monthController.dispose();
    _dayExclusiveController.dispose();
    _weekExclusiveController.dispose();
    _monthExclusiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = VesselThemes.of(context);

    return VesselScaffold(
      title: 'Controls List',
      showBottomNav: false,
      leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. CARDS (standalone, not in _buildSection)
          const VesselHeader(text: 'Cards'),
          const SizedBox(height: 16),
          const Text('Regular:'),
          const SizedBox(height: 8),
          const VesselCard(
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            ),
          ),
          const VesselCard(
            child: Text(
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            ),
          ),
          const SizedBox(height: 8),
          const Text('Transparent:'),
          const SizedBox(height: 8),
          const VesselCard(
            transparent: true,
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            ),
          ),
          const VesselCard(
            transparent: true,
            child: Text(
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            ),
          ),
          const SizedBox(height: 8),
          const Text('Attention:'),
          const SizedBox(height: 8),
          const VesselAttentionCard(
            child: Text('Danger-tinted attention card.'),
          ),
          const SizedBox(height: 16),

          // 1b. TILES
          _buildSection('Tiles', [
            SizedBox(
              width: 160,
              height: VesselLayout.vocabTileHeight,
              child: VesselTile(
                onTap: () {},
                child: Stack(
                  children: [
                    Positioned(
                      top: VesselLayout.vocabTileHeaderTop,
                      left: VesselLayout.vocabTileHeaderLeft,
                      right: VesselLayout.vocabTileHeaderRight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(
                              0,
                              VesselLayout.deckIconTopOffset,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(
                                VesselLayout.deckIconPadding,
                              ),
                              decoration: BoxDecoration(
                                color: t.deckIconBackground,
                                borderRadius: BorderRadius.circular(
                                  t.deckIconBorderRadius,
                                ),
                              ),
                              child: Icon(
                                PhosphorIconsRegular.handWaving,
                                size: VesselLayout.vocabTileIconSize,
                                color: t.deckIconColor,
                              ),
                            ),
                          ),
                          SizedBox(width: VesselLayout.vocabTileHeaderGap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '14 concepts',
                                  textAlign: TextAlign.end,
                                  style: VesselFonts.textTileCounter.copyWith(
                                    color: t.tileForeground,
                                  ),
                                ),
                                SizedBox(
                                  height: VesselLayout.vocabTileHeaderRowGap,
                                ),
                                const VesselProgressBar(
                                  value: 0.42,
                                  mode: VesselProgressBarMode.compact,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: VesselLayout.vocabTileNameTop,
                      left: VesselLayout.vocabTileNameLeft,
                      right: VesselLayout.vocabTileNameRight,
                      child: Text(
                        'First Contact',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VesselFonts.textTileHeader.copyWith(
                          color: t.tileForeground,
                        ),
                      ),
                    ),
                    Positioned(
                      top: VesselLayout.vocabTileWordsTop,
                      left: VesselLayout.vocabTileWordsLeft,
                      right: VesselLayout.vocabTileWordsRight,
                      child: Text(
                        'hello, goodbye, please, thank you',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: VesselFonts.textTileContent.copyWith(
                          color: t.tileForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),

          // 1c. ANSWER TILES
          _buildSection('Answer Tiles', [
            SizedBox(
              height: 80,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: VesselLayout.gapS,
                mainAxisSpacing: VesselLayout.gapS,
                childAspectRatio: VesselLayout.roundOptionTileAspectRatio,
                children: [
                  VesselAnswerTile(label: 'kupiti', onTap: () {}),
                  VesselAnswerTile(label: 'prodati', onTap: () {}),
                ],
              ),
            ),
          ]),

          // 2. HEADER
          _buildSection('Header', [
            const VesselHeader(text: 'Section Header'),
          ]),

          // 3. BUTTONS
          _buildSection('Buttons', [
            // Medium - all color variations
            const Text('Medium - Color variations:'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselButton(label: 'Base', onPressed: () {}),
                VesselButton(label: 'Base', icon: PhosphorIconsRegular.star, onPressed: () {}),
                VesselButton(icon: PhosphorIconsRegular.star, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselAccentButton(label: 'Accent', onPressed: () {}),
                VesselAccentButton(
                  label: 'Accent',
                  icon: PhosphorIconsRegular.check,
                  onPressed: () {},
                ),
                VesselAccentButton(icon: PhosphorIconsRegular.check, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselDangerButton(label: 'Danger', onPressed: () {}),
                VesselDangerButton(
                  label: 'Danger',
                  icon: PhosphorIconsRegular.warning,
                  onPressed: () {},
                ),
                VesselDangerButton(icon: PhosphorIconsRegular.warning, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            // Size variations - base only
            const Text('Size variations (Base):'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselButton(
                  label: 'Small',
                  onPressed: () {},
                  size: VesselButtonSize.small,
                ),
                VesselButton(
                  label: 'Small',
                  icon: PhosphorIconsRegular.star,
                  onPressed: () {},
                  size: VesselButtonSize.small,
                ),
                VesselButton(
                  icon: PhosphorIconsRegular.star,
                  onPressed: () {},
                  size: VesselButtonSize.small,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselButton(label: 'Medium', onPressed: () {}),
                VesselButton(label: 'Medium', icon: PhosphorIconsRegular.star, onPressed: () {}),
                VesselButton(icon: PhosphorIconsRegular.star, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselButton(
                  label: 'Large',
                  onPressed: () {},
                  size: VesselButtonSize.large,
                ),
                VesselButton(
                  label: 'Large',
                  icon: PhosphorIconsRegular.star,
                  onPressed: () {},
                  size: VesselButtonSize.large,
                ),
                VesselButton(
                  icon: PhosphorIconsRegular.star,
                  onPressed: () {},
                  size: VesselButtonSize.large,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Disabled
            const Text('Disabled:'),
            const SizedBox(height: 8),
            const Row(
              children: [
                VesselButton(label: 'Disabled', onPressed: null),
                VesselButton(
                  label: 'Disabled',
                  icon: PhosphorIconsRegular.star,
                  onPressed: null,
                ),
                VesselButton(icon: PhosphorIconsRegular.star, onPressed: null),
              ],
            ),
            const SizedBox(height: 16),
            // Condensed
            const Text('Condensed (small):'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselButton(
                  label: 'Small',
                  onPressed: () {},
                  size: VesselButtonSize.small,
                  condensed: true,
                ),
                VesselButton(
                  label: 'Small',
                  icon: PhosphorIconsRegular.star,
                  onPressed: () {},
                  size: VesselButtonSize.small,
                  condensed: true,
                ),
                VesselButton(
                  icon: PhosphorIconsRegular.star,
                  onPressed: () {},
                  size: VesselButtonSize.small,
                  condensed: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Condensed (medium):'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselButton(
                  label: 'Medium',
                  onPressed: () {},
                  condensed: true,
                ),
                VesselButton(
                  label: 'Medium',
                  icon: PhosphorIconsRegular.star,
                  onPressed: () {},
                  condensed: true,
                ),
                VesselButton(
                  icon: PhosphorIconsRegular.star,
                  onPressed: () {},
                  condensed: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Condensed (large):'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselButton(
                  label: 'Large',
                  onPressed: () {},
                  size: VesselButtonSize.large,
                  condensed: true,
                ),
                VesselButton(
                  label: 'Large',
                  icon: PhosphorIconsRegular.star,
                  onPressed: () {},
                  size: VesselButtonSize.large,
                  condensed: true,
                ),
                VesselButton(
                  icon: PhosphorIconsRegular.star,
                  onPressed: () {},
                  size: VesselButtonSize.large,
                  condensed: true,
                ),
              ],
            ),
          ]),

          // 4. TEXT BUTTONS
          _buildSection('Text Buttons', [
            // Size variations
            const Text('Size variations:'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselTextButton(
                  label: 'Small',
                  onPressed: () {},
                  size: VesselButtonSize.small,
                ),
                VesselTextButton(
                  label: 'Small',
                  icon: PhosphorIconsRegular.arrowClockwise,
                  onPressed: () {},
                  size: VesselButtonSize.small,
                ),
                VesselTextButton(
                  icon: PhosphorIconsRegular.arrowClockwise,
                  onPressed: () {},
                  size: VesselButtonSize.small,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselTextButton(label: 'Medium', onPressed: () {}),
                VesselTextButton(
                  label: 'Medium',
                  icon: PhosphorIconsRegular.arrowClockwise,
                  onPressed: () {},
                ),
                VesselTextButton(icon: PhosphorIconsRegular.arrowClockwise, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselTextButton(
                  label: 'Large',
                  onPressed: () {},
                  size: VesselButtonSize.large,
                ),
                VesselTextButton(
                  label: 'Large',
                  icon: PhosphorIconsRegular.arrowClockwise,
                  onPressed: () {},
                  size: VesselButtonSize.large,
                ),
                VesselTextButton(
                  icon: PhosphorIconsRegular.arrowClockwise,
                  onPressed: () {},
                  size: VesselButtonSize.large,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Accent text
            const Text('Accent:'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselAccentTextButton(label: 'Accent', onPressed: () {}),
                VesselAccentTextButton(
                  label: 'Accent',
                  icon: PhosphorIconsRegular.check,
                  onPressed: () {},
                ),
                VesselAccentTextButton(icon: PhosphorIconsRegular.check, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            // Danger text
            const Text('Danger:'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselDangerTextButton(label: 'Danger', onPressed: () {}),
                VesselDangerTextButton(
                  label: 'Danger',
                  icon: PhosphorIconsRegular.warning,
                  onPressed: () {},
                ),
                VesselDangerTextButton(icon: PhosphorIconsRegular.warning, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            // Disabled
            const Text('Disabled:'),
            const SizedBox(height: 8),
            const Row(
              children: [
                VesselTextButton(label: 'Disabled', onPressed: null),
                VesselTextButton(
                  label: 'Disabled',
                  icon: PhosphorIconsRegular.arrowClockwise,
                  onPressed: null,
                ),
                VesselTextButton(icon: PhosphorIconsRegular.arrowClockwise, onPressed: null),
              ],
            ),
            const SizedBox(height: 16),
            // Condensed text buttons
            const Text('Condensed (small):'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselTextButton(
                  label: 'Small',
                  onPressed: () {},
                  size: VesselButtonSize.small,
                  condensed: true,
                ),
                VesselTextButton(
                  icon: PhosphorIconsRegular.arrowClockwise,
                  onPressed: () {},
                  size: VesselButtonSize.small,
                  condensed: true,
                ),
                VesselAccentTextButton(
                  icon: PhosphorIconsRegular.check,
                  onPressed: () {},
                  size: VesselButtonSize.small,
                  condensed: true,
                ),
                VesselDangerTextButton(
                  icon: PhosphorIconsRegular.warning,
                  onPressed: () {},
                  size: VesselButtonSize.small,
                  condensed: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Condensed (medium):'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselTextButton(
                  label: 'Medium',
                  onPressed: () {},
                  condensed: true,
                ),
                VesselTextButton(
                  icon: PhosphorIconsRegular.arrowClockwise,
                  onPressed: () {},
                  condensed: true,
                ),
                VesselAccentTextButton(
                  icon: PhosphorIconsRegular.check,
                  onPressed: () {},
                  condensed: true,
                ),
                VesselDangerTextButton(
                  icon: PhosphorIconsRegular.warning,
                  onPressed: () {},
                  condensed: true,
                ),
              ],
            ),
          ]),

          // 5. BUTTON GROUPS
          _buildSection('Button Groups', [
            const Text('Icon only (small):'),
            const SizedBox(height: 8),
            ProjectButtonGroup(
              size: VesselButtonSize.small,
              items: [
                VesselButtonGroupItem(icon: PhosphorIconsRegular.minus, onPressed: () {}),
                VesselButtonGroupItem(icon: PhosphorIconsRegular.plus, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Icon only (medium):'),
            const SizedBox(height: 8),
            ProjectButtonGroup(
              items: [
                VesselButtonGroupItem(icon: PhosphorIconsRegular.minus, onPressed: () {}),
                VesselButtonGroupItem(icon: PhosphorIconsRegular.plus, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('With labels:'),
            const SizedBox(height: 8),
            ProjectButtonGroup(
              items: [
                VesselButtonGroupItem(
                  label: 'Prev',
                  icon: PhosphorIconsRegular.arrowLeft,
                  onPressed: () {},
                ),
                VesselButtonGroupItem(
                  label: 'Next',
                  icon: PhosphorIconsRegular.arrowRight,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Three buttons:'),
            const SizedBox(height: 8),
            ProjectButtonGroup(
              items: [
                VesselButtonGroupItem(
                  icon: PhosphorIconsRegular.textAlignLeft,
                  onPressed: () {},
                ),
                VesselButtonGroupItem(
                  icon: PhosphorIconsRegular.textAlignCenter,
                  onPressed: () {},
                ),
                VesselButtonGroupItem(
                  icon: PhosphorIconsRegular.textAlignRight,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Expanded (full width):'),
            const SizedBox(height: 8),
            ProjectButtonGroup(
              expanded: true,
              items: [
                VesselButtonGroupItem(icon: PhosphorIconsRegular.minus, onPressed: () {}),
                VesselButtonGroupItem(icon: PhosphorIconsRegular.plus, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('With disabled button:'),
            const SizedBox(height: 8),
            ProjectButtonGroup(
              items: [
                const VesselButtonGroupItem(
                  icon: PhosphorIconsRegular.minus,
                  onPressed: null,
                ),
                VesselButtonGroupItem(icon: PhosphorIconsRegular.plus, onPressed: () {}),
              ],
            ),
          ]),

          // 6. INPUTS
          _buildSection('Inputs', [
            TextField(
              style: VesselInputStyles.textStyle(context),
              decoration: VesselInputStyles.decoration(
                context: context,
                label: 'Text Field',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              style: VesselInputStyles.textStyle(context),
              decoration: VesselInputStyles.decoration(
                context: context,
                label: 'Number Field',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('VesselTextInput:'),
            const SizedBox(height: 8),
            VesselTextInput(
              controller: _textController,
              label: 'Label',
              hint: 'Placeholder text',
            ),
            const SizedBox(height: 16),
            const Text('VesselTextInput (multiline):'),
            const SizedBox(height: 8),
            VesselTextInput(
              hint: 'Multiline input...',
              maxLines: 4,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            const Text('VesselDropdown:'),
            const SizedBox(height: 8),
            VesselDropdown<String>(
              value: _demoDropdownValue,
              onChanged: (v) => setState(() => _demoDropdownValue = v),
              label: 'Fruit',
              items: const [
                VesselDropdownItem(value: 'apple', label: 'Apple'),
                VesselDropdownItem(value: 'banana', label: 'Banana'),
                VesselDropdownItem(value: 'cherry', label: 'Cherry'),
              ],
            ),
          ]),

          // 7. CHECKBOXES
          _buildSection('Checkboxes', [
            const Text('VesselCheckbox (base):'),
            const SizedBox(height: 4),
            VesselCheckbox(
              value: _demoCheckbox,
              onChanged: (value) =>
                  setState(() => _demoCheckbox = value ?? false),
            ),
            const SizedBox(height: 16),
            const Text('VesselCheckboxLabeled (label right):'),
            const SizedBox(height: 4),
            VesselCheckboxLabeled(
              label: 'Label Right',
              value: _demoCheckbox,
              onChanged: (value) =>
                  setState(() => _demoCheckbox = value ?? false),
            ),
            const SizedBox(height: 16),
            const Text('VesselCheckboxLabeled (label left):'),
            const SizedBox(height: 4),
            VesselCheckboxLabeled(
              label: 'Label Left',
              value: _demoCheckbox,
              labelPosition: VesselLabelPosition.left,
              onChanged: (value) =>
                  setState(() => _demoCheckbox = value ?? false),
            ),
            const SizedBox(height: 16),
            const Text('VesselCheckboxLabeled (fullWidth):'),
            const SizedBox(height: 4),
            VesselCheckboxLabeled(
              label: 'Full Width Label',
              value: _demoCheckbox,
              labelPosition: VesselLabelPosition.left,
              fullWidth: true,
              onChanged: (value) =>
                  setState(() => _demoCheckbox = value ?? false),
            ),
          ]),

          // 8. SWITCHES
          _buildSection('Switches', [
            const Text('VesselSwitch (base):'),
            const SizedBox(height: 4),
            VesselSwitch(
              value: _demoSwitch,
              onChanged: (value) =>
                  setState(() => _demoSwitch = value),
            ),
            const SizedBox(height: 16),
            const Text('VesselSwitchLabeled (label left):'),
            const SizedBox(height: 4),
            VesselSwitchLabeled(
              label: 'Label Left',
              value: _demoSwitch,
              onChanged: (value) =>
                  setState(() => _demoSwitch = value),
            ),
            const SizedBox(height: 16),
            const Text('VesselSwitchLabeled (label right):'),
            const SizedBox(height: 4),
            VesselSwitchLabeled(
              label: 'Label Right',
              value: _demoSwitch,
              labelPosition: VesselLabelPosition.right,
              onChanged: (value) =>
                  setState(() => _demoSwitch = value),
            ),
            const SizedBox(height: 16),
            const Text('VesselSwitchLabeled (fullWidth):'),
            const SizedBox(height: 4),
            VesselSwitchLabeled(
              label: 'Full Width Label',
              value: _demoSwitch,
              fullWidth: true,
              onChanged: (value) =>
                  setState(() => _demoSwitch = value),
            ),
          ]),

          // 9. RADIO TILES (srpski-specific)
          _buildSection('Radio Tiles', [
            VesselRadioTile<String>(
              value: 'A',
              groupValue: _radioValue,
              label: 'Option A',
              onChanged: (v) {
                if (v != null) setState(() => _radioValue = v);
              },
            ),
            VesselRadioTile<String>(
              value: 'B',
              groupValue: _radioValue,
              label: 'Option B',
              onChanged: (v) {
                if (v != null) setState(() => _radioValue = v);
              },
            ),
            VesselRadioTile<String>(
              value: 'C',
              groupValue: _radioValue,
              label: 'Option C (disabled)',
              onChanged: null,
            ),
          ]),

          // 11. RADIO GRID
          _buildSection('Radio Grid', [
            const Text('2x2 Grid (default):'),
            const SizedBox(height: 8),
            ProjectRadioGrid<String>(
              options: const [
                VesselRadioGridOption(
                  value: 'Time',
                  label: 'Time',
                  icon: PhosphorIconsRegular.timer,
                ),
                VesselRadioGridOption(
                  value: 'Counter',
                  label: 'Counter',
                  icon: PhosphorIconsRegular.plusCircle,
                ),
                VesselRadioGridOption(
                  value: 'Check',
                  label: 'Check',
                  icon: PhosphorIconsRegular.check,
                ),
                VesselRadioGridOption(
                  value: 'Streak',
                  label: 'Streak',
                  icon: PhosphorIconsRegular.fire,
                ),
              ],
              selectedValue: _demoGridRadio,
              onChanged: (value) => setState(() => _demoGridRadio = value),
            ),
            const SizedBox(height: 16),
            const Text('3 columns:'),
            const SizedBox(height: 8),
            ProjectRadioGrid<String>(
              options: const [
                VesselRadioGridOption(value: 'Time', label: 'Time'),
                VesselRadioGridOption(value: 'Counter', label: 'Counter'),
                VesselRadioGridOption(value: 'Check', label: 'Check'),
                VesselRadioGridOption(value: 'Streak', label: 'Streak'),
                VesselRadioGridOption(value: 'Other', label: 'Other'),
                VesselRadioGridOption(value: 'More', label: 'More'),
              ],
              selectedValue: _demoGridRadio,
              columns: 3,
              onChanged: (value) => setState(() => _demoGridRadio = value),
            ),
          ]),

          // 12. DATE PICKER
          _buildSection('Date Picker', [
            const Text('Start Date:'),
            const SizedBox(height: 8),
            VesselDatePicker(
              label: 'Start Date',
              selectedDate: _demoStartDate,
              placeholder: 'Select date',
              onDateSelected: (date) => setState(() => _demoStartDate = date),
            ),
            const SizedBox(height: 16),
            const Text('End Date (optional):'),
            const SizedBox(height: 8),
            VesselDatePicker(
              label: 'End Date',
              selectedDate: _demoEndDate,
              placeholder: 'Not set',
              firstDate: _demoStartDate,
              onDateSelected: (date) => setState(() => _demoEndDate = date),
            ),
          ]),

          // 13. HOUR PICKER (srpski-specific)
          _buildSection('Hour Picker', [
            VesselHourPicker(
              label: 'Day start hour',
              description: 'Pick when the day begins',
              selectedHour: _selectedHour,
              onHourSelected: (h) => setState(() => _selectedHour = h),
            ),
          ]),

          // 14. SLIDER - COUNTER MODE
          _buildSection('Slider - Counter Mode', [
            const Text('Linear (0-100):'),
            const SizedBox(height: 8),
            VesselSliderInput(
              value: _demoSliderCounter,
              min: 0,
              max: 100,
              mode: VesselSliderInputMode.counter,
              onChanged: (value) => setState(() => _demoSliderCounter = value),
            ),
            const SizedBox(height: 16),
            const Text('Zoned (0-10000):'),
            const SizedBox(height: 8),
            VesselSliderInput(
              value: _demoSliderCounterZoned,
              min: 0,
              max: 10000,
              mode: VesselSliderInputMode.counter,
              zoned: true,
              onChanged: (value) =>
                  setState(() => _demoSliderCounterZoned = value),
            ),
            const SizedBox(height: 16),
            const Text('With buttons:'),
            const SizedBox(height: 8),
            VesselSliderInput(
              value: _demoSliderCounterButtons,
              min: 0,
              max: 10000,
              mode: VesselSliderInputMode.counter,
              zoned: true,
              showButtons: true,
              onChanged: (value) =>
                  setState(() => _demoSliderCounterButtons = value),
            ),
          ]),

          // 15. TIME SLIDER
          _buildSection('Time Slider', [
            const Text('Default:'),
            const SizedBox(height: 8),
            VesselTimeSlider(
              value: _demoSliderTime,
              max: 480,
              onChanged: (value) => setState(() => _demoSliderTime = value),
            ),
            const SizedBox(height: 16),
            const Text('With buttons:'),
            const SizedBox(height: 8),
            VesselTimeSlider(
              value: _demoSliderTimeButtons,
              max: 480,
              showButtons: true,
              onChanged: (value) =>
                  setState(() => _demoSliderTimeButtons = value),
            ),
          ]),

          // 16. DIVIDER
          _buildSection('Divider', [
            const VesselDivider(),
          ]),

          // 17. TAGS
          _buildSection('Tags', [
            const Text('Icon (2-letter):'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                VesselTagLabel(
                  tag: Tag(id: '1', name: 'Work', color: TagColor.color1),
                  size: VesselTagLabelSize.icon,
                ),
                VesselTagLabel(
                  tag: Tag(id: '2', name: 'Very Urgent', color: TagColor.color2),
                  size: VesselTagLabelSize.icon,
                ),
                VesselTagLabel(
                  tag: Tag(id: '3', name: 'Personal', color: TagColor.color3),
                  size: VesselTagLabelSize.icon,
                ),
                VesselTagLabel(
                  tag: Tag(id: '4', name: 'No Color', color: TagColor.none),
                  size: VesselTagLabelSize.icon,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Tiny:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                VesselTagLabel(
                  tag: Tag(id: '1', name: 'Blue', color: TagColor.color1),
                  size: VesselTagLabelSize.tiny,
                ),
                VesselTagLabel(
                  tag: Tag(id: '2', name: 'Green', color: TagColor.color2),
                  size: VesselTagLabelSize.tiny,
                ),
                VesselTagLabel(
                  tag: Tag(id: '3', name: 'Purple', color: TagColor.color3),
                  size: VesselTagLabelSize.tiny,
                ),
                VesselTagLabel(
                  tag: Tag(id: '4', name: 'No Color', color: TagColor.none),
                  size: VesselTagLabelSize.tiny,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Regular:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                VesselTagLabel(
                  tag: Tag(id: '1', name: 'Blue', color: TagColor.color1),
                  size: VesselTagLabelSize.regular,
                ),
                VesselTagLabel(
                  tag: Tag(id: '2', name: 'Green', color: TagColor.color2),
                  size: VesselTagLabelSize.regular,
                ),
                VesselTagLabel(
                  tag: Tag(id: '3', name: 'Purple', color: TagColor.color3),
                  size: VesselTagLabelSize.regular,
                ),
                VesselTagLabel(
                  tag: Tag(id: '4', name: 'No Color', color: TagColor.none),
                  size: VesselTagLabelSize.regular,
                ),
              ],
            ),
          ]),

          // 18. TAG CHIPS
          _buildSection('Tag Chips', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                VesselTagChip(tag: Tag(id: '1', name: 'Design', color: TagColor.color1)),
                VesselTagChip(tag: Tag(id: '2', name: 'Urgent', color: TagColor.color2)),
                VesselTagChip(tag: Tag(id: '3', name: 'Review', color: TagColor.color3)),
                VesselTagChip(tag: Tag(id: '4', name: 'No Color', color: TagColor.none)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Tag Color Preview:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TagColor.values.map((tc) {
                return VesselTagColorPreview(
                  tagColor: tc,
                  isSelected: tc == _selectedTagColor,
                  onTap: () => setState(() => _selectedTagColor = tc),
                );
              }).toList(),
            ),
          ]),

          // 19. SNACKBAR
          _buildSection('Snackbar', [
            const Text('VesselSnackBar (themed):'),
            const SizedBox(height: 8),
            Row(
              children: [
                VesselButton(
                  label: 'Show Snackbar',
                  onPressed: () {
                    VesselSnackBar.show(context, 'This is a themed snackbar message');
                  },
                ),
              ],
            ),
          ]),

          // 20. NOTES
          _buildSection('Notes', [
            const Text('Default:'),
            const SizedBox(height: 8),
            const VesselNote(text: 'This is an informational note.'),
            const SizedBox(height: 16),
            const Text('Long text:'),
            const SizedBox(height: 8),
            const VesselNote(text: 'Slider range adjusts based on your history. Give it some time :)'),
          ]),

          // 21. GAPS
          _buildSection('Gaps (VesselGap)', [
            const Text('Vertical:'),
            const SizedBox(height: 8),
            _vGapDemo('xxs (2)', const VesselGap.xxs(), t),
            _vGapDemo('xs (4)', const VesselGap.xs(), t),
            _vGapDemo('s (8)', const VesselGap.s(), t),
            _vGapDemo('m (12)', const VesselGap.m(), t),
            _vGapDemo('l (16)', const VesselGap.l(), t),
            _vGapDemo('xl (24)', const VesselGap.xl(), t),
            _vGapDemo('xxl (48)', const VesselGap.xxl(), t),
            const SizedBox(height: 16),
            const Text('Horizontal:'),
            const SizedBox(height: 8),
            _hGapDemo('hxxs (2)', const VesselGap.hxxs(), t),
            _hGapDemo('hxs (4)', const VesselGap.hxs(), t),
            _hGapDemo('hs (8)', const VesselGap.hs(), t),
            _hGapDemo('hm (12)', const VesselGap.hm(), t),
            _hGapDemo('hl (16)', const VesselGap.hl(), t),
            _hGapDemo('hxl (24)', const VesselGap.hxl(), t),
          ]),

          // 22. BOTTOM SHEETS (srpski-specific)
          _buildSection('Bottom Sheets', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                VesselButton(
                  label: 'Project Sheet',
                  onPressed: () {
                    final t = VesselThemes.of(context);
                    showVesselBottomSheet(
                      context: context,
                      builder: (sheetContext) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Project Bottom Sheet',
                            style: VesselFonts.textSheetTitle.copyWith(color: t.textPrimary),
                          ),
                          const VesselGap.m(),
                          Text(
                            'With blur support. Content goes here.',
                            style: VesselFonts.textBody.copyWith(color: t.textSecondary),
                          ),
                          const VesselGap.l(),
                          VesselButton(
                            label: 'Close',
                            onPressed: () => Navigator.of(sheetContext).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                VesselButton(
                  label: 'Mode Sheet',
                  onPressed: () {
                    showModeBottomSheet(
                      context,
                      l10n,
                      targetLangCode: 'sr',
                      nativeLangCode: 'en',
                      nativeLangName: 'English',
                      targetLangName: 'Serbian',
                    );
                  },
                ),
                VesselButton(
                  label: 'Count Sheet',
                  onPressed: () {
                    showCountBottomSheet(context, l10n, totalCount: 20);
                  },
                ),
              ],
            ),
          ]),

          // 22. LEGACY HEADER
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: VesselHeader(text: 'Legacy'),
          ),

          // 23. INPUT ROWS
          _buildSection('Input Rows', [
            const Text('Regular (all fields can have values):'),
            const SizedBox(height: 8),
            ProjectInputRow(
              fields: [
                VesselInputRowField(
                  label: 'Day',
                  hint: '0',
                  controller: _dayController,
                  keyboardType: TextInputType.number,
                ),
                VesselInputRowField(
                  label: 'Week',
                  hint: '0',
                  controller: _weekController,
                  keyboardType: TextInputType.number,
                ),
                VesselInputRowField(
                  label: 'Month',
                  hint: '0',
                  controller: _monthController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Exclusive (only one field can have value):'),
            const SizedBox(height: 8),
            ProjectInputRow(
              exclusive: true,
              fields: [
                VesselInputRowField(
                  label: 'Day',
                  hint: '0',
                  controller: _dayExclusiveController,
                  keyboardType: TextInputType.number,
                ),
                VesselInputRowField(
                  label: 'Week',
                  hint: '0',
                  controller: _weekExclusiveController,
                  keyboardType: TextInputType.number,
                ),
                VesselInputRowField(
                  label: 'Month',
                  hint: '0',
                  controller: _monthExclusiveController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ]),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return VesselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: VesselFonts.textSubtitle),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _vGapDemo(String label, Widget gap, VesselThemeData t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: VesselFonts.textCaption.copyWith(color: t.textSecondary)),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 2, color: t.accentColor),
                gap,
                Container(height: 2, color: t.accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hGapDemo(String label, Widget gap, VesselThemeData t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: VesselFonts.textCaption.copyWith(color: t.textSecondary)),
          ),
          Container(width: 2, height: 24, color: t.accentColor),
          gap,
          Container(width: 2, height: 24, color: t.accentColor),
        ],
      ),
    );
  }
}
