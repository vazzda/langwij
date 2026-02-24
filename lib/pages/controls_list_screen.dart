import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../app/theme/app_themes.dart';
import '../entities/tag/tag.dart';
import '../shared/ui/buttons/project_buttons.dart';
import '../shared/ui/buttons/project_button_group.dart';
import '../shared/ui/card/project_card.dart';
import '../shared/ui/divider/project_divider.dart';
import '../shared/ui/inputs/app_choice_chip.dart';
import '../shared/ui/inputs/project_date_picker.dart';
import '../shared/ui/inputs/project_hour_picker.dart';
import '../shared/ui/inputs/project_input_row.dart';
import '../shared/ui/inputs/project_input_styles.dart';
import '../shared/ui/inputs/project_radio_grid.dart';
import '../shared/ui/inputs/project_radio_tile.dart';
import '../shared/ui/inputs/project_slider_input.dart';
import '../shared/ui/inputs/project_text_input.dart';
import '../shared/ui/inputs/project_time_slider.dart';
import '../shared/ui/inputs/project_toggles.dart';
import '../shared/ui/note/project_note.dart';
import '../shared/ui/snackbar/project_snackbar.dart';
import '../shared/ui/tag/tag_chip.dart';
import '../shared/ui/tag/tag_label.dart';
import '../shared/ui/text/project_header.dart';
import '../shared/ui/bottom_sheet/project_bottom_sheet.dart';
import '../shared/ui/bottom_sheet/quiz_bottom_sheets.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';

/// Developer controls list screen - Showcase all UI components
class ControlsListScreen extends StatefulWidget {
  const ControlsListScreen({super.key});

  @override
  State<ControlsListScreen> createState() => _ControlsListScreenState();
}

class _ControlsListScreenState extends State<ControlsListScreen> {
  bool _demoCheckbox = true;
  bool _demoSwitch = true;
  bool _chipSelected = false;
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

  // State for ProjectDatePicker demo
  DateTime? _demoStartDate;
  DateTime? _demoEndDate;

  // State for ProjectSliderInput demo
  int _demoSliderCounter = 50;
  int _demoSliderCounterZoned = 500;
  int _demoSliderCounterButtons = 250;
  int _demoSliderTime = 90;
  int _demoSliderTimeButtons = 75;

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

    return ScreenLayoutWidget(
      title: 'Controls List',
      showBottomNav: false,
      leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. CARDS (standalone, not in _buildSection)
          const ProjectHeader(text: 'Cards'),
          const SizedBox(height: 16),
          const Text('Regular:'),
          const SizedBox(height: 8),
          const ProjectCard(
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            ),
          ),
          const ProjectCard(
            child: Text(
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            ),
          ),
          const SizedBox(height: 8),
          const Text('Transparent:'),
          const SizedBox(height: 8),
          const ProjectCard(
            transparent: true,
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            ),
          ),
          const ProjectCard(
            transparent: true,
            child: Text(
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            ),
          ),
          const SizedBox(height: 8),
          const Text('Attention:'),
          const SizedBox(height: 8),
          const ProjectAttentionCard(
            child: Text('Danger-tinted attention card.'),
          ),
          const SizedBox(height: 16),

          // 2. HEADER
          _buildSection('Header', [
            const ProjectHeader(text: 'Section Header'),
          ]),

          // 3. BUTTONS
          _buildSection('Buttons', [
            // Medium - all color variations
            const Text('Medium - Color variations:'),
            const SizedBox(height: 8),
            Row(
              children: [
                BaseButton(label: 'Base', onPressed: () {}),
                BaseButton(label: 'Base', icon: Icons.star, onPressed: () {}),
                BaseButton(icon: Icons.star, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                AccentButton(label: 'Accent', onPressed: () {}),
                AccentButton(
                  label: 'Accent',
                  icon: Icons.check,
                  onPressed: () {},
                ),
                AccentButton(icon: Icons.check, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                DangerButton(label: 'Danger', onPressed: () {}),
                DangerButton(
                  label: 'Danger',
                  icon: Icons.warning,
                  onPressed: () {},
                ),
                DangerButton(icon: Icons.warning, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            // Size variations - base only
            const Text('Size variations (Base):'),
            const SizedBox(height: 8),
            Row(
              children: [
                BaseButton(
                  label: 'Small',
                  onPressed: () {},
                  size: ButtonSize.small,
                ),
                BaseButton(
                  label: 'Small',
                  icon: Icons.star,
                  onPressed: () {},
                  size: ButtonSize.small,
                ),
                BaseButton(
                  icon: Icons.star,
                  onPressed: () {},
                  size: ButtonSize.small,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                BaseButton(label: 'Medium', onPressed: () {}),
                BaseButton(label: 'Medium', icon: Icons.star, onPressed: () {}),
                BaseButton(icon: Icons.star, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                BaseButton(
                  label: 'Large',
                  onPressed: () {},
                  size: ButtonSize.large,
                ),
                BaseButton(
                  label: 'Large',
                  icon: Icons.star,
                  onPressed: () {},
                  size: ButtonSize.large,
                ),
                BaseButton(
                  icon: Icons.star,
                  onPressed: () {},
                  size: ButtonSize.large,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Disabled
            const Text('Disabled:'),
            const SizedBox(height: 8),
            const Row(
              children: [
                BaseButton(label: 'Disabled', onPressed: null),
                BaseButton(
                  label: 'Disabled',
                  icon: Icons.star,
                  onPressed: null,
                ),
                BaseButton(icon: Icons.star, onPressed: null),
              ],
            ),
            const SizedBox(height: 16),
            // Condensed
            const Text('Condensed (small):'),
            const SizedBox(height: 8),
            Row(
              children: [
                BaseButton(
                  label: 'Small',
                  onPressed: () {},
                  size: ButtonSize.small,
                  condensed: true,
                ),
                BaseButton(
                  label: 'Small',
                  icon: Icons.star,
                  onPressed: () {},
                  size: ButtonSize.small,
                  condensed: true,
                ),
                BaseButton(
                  icon: Icons.star,
                  onPressed: () {},
                  size: ButtonSize.small,
                  condensed: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Condensed (medium):'),
            const SizedBox(height: 8),
            Row(
              children: [
                BaseButton(
                  label: 'Medium',
                  onPressed: () {},
                  condensed: true,
                ),
                BaseButton(
                  label: 'Medium',
                  icon: Icons.star,
                  onPressed: () {},
                  condensed: true,
                ),
                BaseButton(
                  icon: Icons.star,
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
                BaseButton(
                  label: 'Large',
                  onPressed: () {},
                  size: ButtonSize.large,
                  condensed: true,
                ),
                BaseButton(
                  label: 'Large',
                  icon: Icons.star,
                  onPressed: () {},
                  size: ButtonSize.large,
                  condensed: true,
                ),
                BaseButton(
                  icon: Icons.star,
                  onPressed: () {},
                  size: ButtonSize.large,
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
                ProjectTextButton(
                  label: 'Small',
                  onPressed: () {},
                  size: ButtonSize.small,
                ),
                ProjectTextButton(
                  label: 'Small',
                  icon: Icons.refresh,
                  onPressed: () {},
                  size: ButtonSize.small,
                ),
                ProjectTextButton(
                  icon: Icons.refresh,
                  onPressed: () {},
                  size: ButtonSize.small,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ProjectTextButton(label: 'Medium', onPressed: () {}),
                ProjectTextButton(
                  label: 'Medium',
                  icon: Icons.refresh,
                  onPressed: () {},
                ),
                ProjectTextButton(icon: Icons.refresh, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ProjectTextButton(
                  label: 'Large',
                  onPressed: () {},
                  size: ButtonSize.large,
                ),
                ProjectTextButton(
                  label: 'Large',
                  icon: Icons.refresh,
                  onPressed: () {},
                  size: ButtonSize.large,
                ),
                ProjectTextButton(
                  icon: Icons.refresh,
                  onPressed: () {},
                  size: ButtonSize.large,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Accent text
            const Text('Accent:'),
            const SizedBox(height: 8),
            Row(
              children: [
                AccentTextButton(label: 'Accent', onPressed: () {}),
                AccentTextButton(
                  label: 'Accent',
                  icon: Icons.check,
                  onPressed: () {},
                ),
                AccentTextButton(icon: Icons.check, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            // Danger text
            const Text('Danger:'),
            const SizedBox(height: 8),
            Row(
              children: [
                DangerTextButton(label: 'Danger', onPressed: () {}),
                DangerTextButton(
                  label: 'Danger',
                  icon: Icons.warning,
                  onPressed: () {},
                ),
                DangerTextButton(icon: Icons.warning, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            // Disabled
            const Text('Disabled:'),
            const SizedBox(height: 8),
            const Row(
              children: [
                ProjectTextButton(label: 'Disabled', onPressed: null),
                ProjectTextButton(
                  label: 'Disabled',
                  icon: Icons.refresh,
                  onPressed: null,
                ),
                ProjectTextButton(icon: Icons.refresh, onPressed: null),
              ],
            ),
            const SizedBox(height: 16),
            // Condensed text buttons
            const Text('Condensed (small):'),
            const SizedBox(height: 8),
            Row(
              children: [
                ProjectTextButton(
                  label: 'Small',
                  onPressed: () {},
                  size: ButtonSize.small,
                  condensed: true,
                ),
                ProjectTextButton(
                  icon: Icons.refresh,
                  onPressed: () {},
                  size: ButtonSize.small,
                  condensed: true,
                ),
                AccentTextButton(
                  icon: Icons.check,
                  onPressed: () {},
                  size: ButtonSize.small,
                  condensed: true,
                ),
                DangerTextButton(
                  icon: Icons.warning,
                  onPressed: () {},
                  size: ButtonSize.small,
                  condensed: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Condensed (medium):'),
            const SizedBox(height: 8),
            Row(
              children: [
                ProjectTextButton(
                  label: 'Medium',
                  onPressed: () {},
                  condensed: true,
                ),
                ProjectTextButton(
                  icon: Icons.refresh,
                  onPressed: () {},
                  condensed: true,
                ),
                AccentTextButton(
                  icon: Icons.check,
                  onPressed: () {},
                  condensed: true,
                ),
                DangerTextButton(
                  icon: Icons.warning,
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
              size: ButtonSize.small,
              items: [
                ProjectButtonGroupItem(icon: Icons.remove, onPressed: () {}),
                ProjectButtonGroupItem(icon: Icons.add, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Icon only (medium):'),
            const SizedBox(height: 8),
            ProjectButtonGroup(
              items: [
                ProjectButtonGroupItem(icon: Icons.remove, onPressed: () {}),
                ProjectButtonGroupItem(icon: Icons.add, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('With labels:'),
            const SizedBox(height: 8),
            ProjectButtonGroup(
              items: [
                ProjectButtonGroupItem(
                  label: 'Prev',
                  icon: Icons.arrow_back,
                  onPressed: () {},
                ),
                ProjectButtonGroupItem(
                  label: 'Next',
                  icon: Icons.arrow_forward,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Three buttons:'),
            const SizedBox(height: 8),
            ProjectButtonGroup(
              items: [
                ProjectButtonGroupItem(
                  icon: Icons.format_align_left,
                  onPressed: () {},
                ),
                ProjectButtonGroupItem(
                  icon: Icons.format_align_center,
                  onPressed: () {},
                ),
                ProjectButtonGroupItem(
                  icon: Icons.format_align_right,
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
                ProjectButtonGroupItem(icon: Icons.remove, onPressed: () {}),
                ProjectButtonGroupItem(icon: Icons.add, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('With disabled button:'),
            const SizedBox(height: 8),
            ProjectButtonGroup(
              items: [
                const ProjectButtonGroupItem(
                  icon: Icons.remove,
                  onPressed: null,
                ),
                ProjectButtonGroupItem(icon: Icons.add, onPressed: () {}),
              ],
            ),
          ]),

          // 6. INPUTS
          _buildSection('Inputs', [
            TextField(
              style: ProjectInputStyles.textStyle(context),
              decoration: ProjectInputStyles.decoration(
                context: context,
                label: 'Text Field',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              style: ProjectInputStyles.textStyle(context),
              decoration: ProjectInputStyles.decoration(
                context: context,
                label: 'Number Field',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('ProjectTextInput:'),
            const SizedBox(height: 8),
            ProjectTextInput(
              controller: _textController,
              label: 'Label',
              hint: 'Placeholder text',
            ),
          ]),

          // 7. CHECKBOXES
          _buildSection('Checkboxes', [
            const Text('ProjectCheckbox (base):'),
            const SizedBox(height: 4),
            ProjectCheckbox(
              value: _demoCheckbox,
              onChanged: (value) =>
                  setState(() => _demoCheckbox = value ?? false),
            ),
            const SizedBox(height: 16),
            const Text('ProjectCheckboxLabeled (label right):'),
            const SizedBox(height: 4),
            ProjectCheckboxLabeled(
              label: 'Label Right',
              value: _demoCheckbox,
              onChanged: (value) =>
                  setState(() => _demoCheckbox = value ?? false),
            ),
            const SizedBox(height: 16),
            const Text('ProjectCheckboxLabeled (label left):'),
            const SizedBox(height: 4),
            ProjectCheckboxLabeled(
              label: 'Label Left',
              value: _demoCheckbox,
              labelPosition: LabelPosition.left,
              onChanged: (value) =>
                  setState(() => _demoCheckbox = value ?? false),
            ),
            const SizedBox(height: 16),
            const Text('ProjectCheckboxLabeled (fullWidth):'),
            const SizedBox(height: 4),
            ProjectCheckboxLabeled(
              label: 'Full Width Label',
              value: _demoCheckbox,
              labelPosition: LabelPosition.left,
              fullWidth: true,
              onChanged: (value) =>
                  setState(() => _demoCheckbox = value ?? false),
            ),
          ]),

          // 8. SWITCHES
          _buildSection('Switches', [
            const Text('ProjectSwitch (base):'),
            const SizedBox(height: 4),
            ProjectSwitch(
              value: _demoSwitch,
              onChanged: (value) =>
                  setState(() => _demoSwitch = value),
            ),
            const SizedBox(height: 16),
            const Text('ProjectSwitchLabeled (label left):'),
            const SizedBox(height: 4),
            ProjectSwitchLabeled(
              label: 'Label Left',
              value: _demoSwitch,
              onChanged: (value) =>
                  setState(() => _demoSwitch = value),
            ),
            const SizedBox(height: 16),
            const Text('ProjectSwitchLabeled (label right):'),
            const SizedBox(height: 4),
            ProjectSwitchLabeled(
              label: 'Label Right',
              value: _demoSwitch,
              labelPosition: LabelPosition.right,
              onChanged: (value) =>
                  setState(() => _demoSwitch = value),
            ),
            const SizedBox(height: 16),
            const Text('ProjectSwitchLabeled (fullWidth):'),
            const SizedBox(height: 4),
            ProjectSwitchLabeled(
              label: 'Full Width Label',
              value: _demoSwitch,
              fullWidth: true,
              onChanged: (value) =>
                  setState(() => _demoSwitch = value),
            ),
          ]),

          // 9. CHOICE CHIPS (srpski-specific)
          _buildSection('Choice Chips', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppChoiceChip(
                  label: 'Selected',
                  selected: true,
                  onSelected: (_) {},
                ),
                AppChoiceChip(
                  label: 'Unselected',
                  selected: false,
                  onSelected: (_) {},
                ),
                AppChoiceChip(
                  label: 'Interactive',
                  selected: _chipSelected,
                  onSelected: (_) {
                    setState(() => _chipSelected = !_chipSelected);
                  },
                ),
              ],
            ),
          ]),

          // 10. RADIO TILES (srpski-specific)
          _buildSection('Radio Tiles', [
            ProjectRadioTile<String>(
              value: 'A',
              groupValue: _radioValue,
              label: 'Option A',
              onChanged: (v) {
                if (v != null) setState(() => _radioValue = v);
              },
            ),
            ProjectRadioTile<String>(
              value: 'B',
              groupValue: _radioValue,
              label: 'Option B',
              onChanged: (v) {
                if (v != null) setState(() => _radioValue = v);
              },
            ),
            ProjectRadioTile<String>(
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
                ProjectRadioGridOption(
                  value: 'Time',
                  label: 'Time',
                  icon: Icons.timer,
                ),
                ProjectRadioGridOption(
                  value: 'Counter',
                  label: 'Counter',
                  icon: Icons.exposure_plus_1,
                ),
                ProjectRadioGridOption(
                  value: 'Check',
                  label: 'Check',
                  icon: Icons.check,
                ),
                ProjectRadioGridOption(
                  value: 'Streak',
                  label: 'Streak',
                  icon: Icons.local_fire_department,
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
                ProjectRadioGridOption(value: 'Time', label: 'Time'),
                ProjectRadioGridOption(value: 'Counter', label: 'Counter'),
                ProjectRadioGridOption(value: 'Check', label: 'Check'),
                ProjectRadioGridOption(value: 'Streak', label: 'Streak'),
                ProjectRadioGridOption(value: 'Other', label: 'Other'),
                ProjectRadioGridOption(value: 'More', label: 'More'),
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
            ProjectDatePicker(
              label: 'Start Date',
              selectedDate: _demoStartDate,
              placeholder: 'Select date',
              onDateSelected: (date) => setState(() => _demoStartDate = date),
            ),
            const SizedBox(height: 16),
            const Text('End Date (optional):'),
            const SizedBox(height: 8),
            ProjectDatePicker(
              label: 'End Date',
              selectedDate: _demoEndDate,
              placeholder: 'Not set',
              firstDate: _demoStartDate,
              onDateSelected: (date) => setState(() => _demoEndDate = date),
            ),
          ]),

          // 13. HOUR PICKER (srpski-specific)
          _buildSection('Hour Picker', [
            ProjectHourPicker(
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
            ProjectSliderInput(
              value: _demoSliderCounter,
              min: 0,
              max: 100,
              mode: SliderInputMode.counter,
              onChanged: (value) => setState(() => _demoSliderCounter = value),
            ),
            const SizedBox(height: 16),
            const Text('Zoned (0-10000):'),
            const SizedBox(height: 8),
            ProjectSliderInput(
              value: _demoSliderCounterZoned,
              min: 0,
              max: 10000,
              mode: SliderInputMode.counter,
              zoned: true,
              onChanged: (value) =>
                  setState(() => _demoSliderCounterZoned = value),
            ),
            const SizedBox(height: 16),
            const Text('With buttons:'),
            const SizedBox(height: 8),
            ProjectSliderInput(
              value: _demoSliderCounterButtons,
              min: 0,
              max: 10000,
              mode: SliderInputMode.counter,
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
            ProjectTimeSlider(
              value: _demoSliderTime,
              max: 480,
              onChanged: (value) => setState(() => _demoSliderTime = value),
            ),
            const SizedBox(height: 16),
            const Text('With buttons:'),
            const SizedBox(height: 8),
            ProjectTimeSlider(
              value: _demoSliderTimeButtons,
              max: 480,
              showButtons: true,
              onChanged: (value) =>
                  setState(() => _demoSliderTimeButtons = value),
            ),
          ]),

          // 16. DIVIDER
          _buildSection('Divider', [
            const ProjectDivider(),
          ]),

          // 17. TAGS
          _buildSection('Tags', [
            const Text('Icon (2-letter):'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                TagLabel(
                  tag: Tag(id: '1', name: 'Work', color: TagColor.color1),
                  size: TagLabelSize.icon,
                ),
                TagLabel(
                  tag: Tag(id: '2', name: 'Very Urgent', color: TagColor.color2),
                  size: TagLabelSize.icon,
                ),
                TagLabel(
                  tag: Tag(id: '3', name: 'Personal', color: TagColor.color3),
                  size: TagLabelSize.icon,
                ),
                TagLabel(
                  tag: Tag(id: '4', name: 'No Color', color: TagColor.none),
                  size: TagLabelSize.icon,
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
                TagLabel(
                  tag: Tag(id: '1', name: 'Blue', color: TagColor.color1),
                  size: TagLabelSize.tiny,
                ),
                TagLabel(
                  tag: Tag(id: '2', name: 'Green', color: TagColor.color2),
                  size: TagLabelSize.tiny,
                ),
                TagLabel(
                  tag: Tag(id: '3', name: 'Purple', color: TagColor.color3),
                  size: TagLabelSize.tiny,
                ),
                TagLabel(
                  tag: Tag(id: '4', name: 'No Color', color: TagColor.none),
                  size: TagLabelSize.tiny,
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
                TagLabel(
                  tag: Tag(id: '1', name: 'Blue', color: TagColor.color1),
                  size: TagLabelSize.regular,
                ),
                TagLabel(
                  tag: Tag(id: '2', name: 'Green', color: TagColor.color2),
                  size: TagLabelSize.regular,
                ),
                TagLabel(
                  tag: Tag(id: '3', name: 'Purple', color: TagColor.color3),
                  size: TagLabelSize.regular,
                ),
                TagLabel(
                  tag: Tag(id: '4', name: 'No Color', color: TagColor.none),
                  size: TagLabelSize.regular,
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
                TagChip(tag: Tag(id: '1', name: 'Design', color: TagColor.color1)),
                TagChip(tag: Tag(id: '2', name: 'Urgent', color: TagColor.color2)),
                TagChip(tag: Tag(id: '3', name: 'Review', color: TagColor.color3)),
                TagChip(tag: Tag(id: '4', name: 'No Color', color: TagColor.none)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Tag Color Preview:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TagColor.values.map((tc) {
                return TagColorPreview(
                  tagColor: tc,
                  isSelected: tc == _selectedTagColor,
                  onTap: () => setState(() => _selectedTagColor = tc),
                );
              }).toList(),
            ),
          ]),

          // 19. SNACKBAR
          _buildSection('Snackbar', [
            const Text('ProjectSnackBar (themed):'),
            const SizedBox(height: 8),
            Row(
              children: [
                BaseButton(
                  label: 'Show Snackbar',
                  onPressed: () {
                    ProjectSnackBar.show(context, 'This is a themed snackbar message');
                  },
                ),
              ],
            ),
          ]),

          // 20. NOTES
          _buildSection('Notes', [
            const Text('Default:'),
            const SizedBox(height: 8),
            const ProjectNote(text: 'This is an informational note.'),
            const SizedBox(height: 16),
            const Text('Long text:'),
            const SizedBox(height: 8),
            const ProjectNote(text: 'Slider range adjusts based on your history. Give it some time :)'),
          ]),

          // 21. BOTTOM SHEETS (srpski-specific)
          _buildSection('Bottom Sheets', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                BaseButton(
                  label: 'Project Sheet',
                  onPressed: () {
                    final t = AppThemes.of(context);
                    showProjectBottomSheet(
                      context: context,
                      builder: (sheetContext) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Project Bottom Sheet',
                              style: AppFontStyles.textSheetTitle.copyWith(color: t.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'With blur support. Content goes here.',
                              style: AppFontStyles.textBody.copyWith(color: t.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            BaseButton(
                              label: 'Close',
                              onPressed: () => Navigator.of(sheetContext).pop(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                BaseButton(
                  label: 'Mode Sheet',
                  onPressed: () {
                    showModeBottomSheet(context, l10n);
                  },
                ),
                BaseButton(
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
            child: ProjectHeader(text: 'Legacy'),
          ),

          // 23. INPUT ROWS
          _buildSection('Input Rows', [
            const Text('Regular (all fields can have values):'),
            const SizedBox(height: 8),
            ProjectInputRow(
              fields: [
                ProjectInputRowField(
                  label: 'Day',
                  hint: '0',
                  controller: _dayController,
                  keyboardType: TextInputType.number,
                ),
                ProjectInputRowField(
                  label: 'Week',
                  hint: '0',
                  controller: _weekController,
                  keyboardType: TextInputType.number,
                ),
                ProjectInputRowField(
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
                ProjectInputRowField(
                  label: 'Day',
                  hint: '0',
                  controller: _dayExclusiveController,
                  keyboardType: TextInputType.number,
                ),
                ProjectInputRowField(
                  label: 'Week',
                  hint: '0',
                  controller: _weekExclusiveController,
                  keyboardType: TextInputType.number,
                ),
                ProjectInputRowField(
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
    return ProjectCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFontStyles.textSubtitle),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
