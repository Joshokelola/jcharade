import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/constants.dart';

class TimerSelector extends StatelessWidget {
  final int selectedDuration;
  final Function(int) onDurationChanged;

  const TimerSelector({
    super.key,
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  bool get _isCustomSelection =>
      !AppConstants.timerDurations.contains(selectedDuration);

  void _handlePresetTap(int duration) {
    HapticFeedback.selectionClick();
    onDurationChanged(duration);
  }

  Future<void> _handleCustomTap(BuildContext context) async {
    final initialMinutes = selectedDuration > 0
        ? (selectedDuration / 60).round().clamp(1, 30)
        : AppConstants.defaultTimerDuration ~/ 60;

    final customDuration = await showDialog<int>(
      context: context,
      builder: (dialogContext) =>
          _CustomDurationDialog(initialMinutes: initialMinutes),
    );

    if (customDuration != null) {
      HapticFeedback.selectionClick();
      onDurationChanged(customDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (final duration in AppConstants.timerDurations) {
      final isSelected = selectedDuration == duration;
      children.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _TimerOption(
              label: '${duration ~/ 60}m',
              subtitle: _getPresetLabel(duration),
              icon: Icons.timer_outlined,
              isSelected: isSelected,
              onTap: () => _handlePresetTap(duration),
            ),
          ),
        ),
      );
    }

    final isCustomSelected = _isCustomSelection;
    children.add(
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: _TimerOption(
            label: 'Custom',
            subtitle: isCustomSelected
                ? _formatDurationLabel(selectedDuration)
                : 'Tap to set',
            icon: Icons.edit_outlined,
            isSelected: isCustomSelected,
            onTap: () => _handleCustomTap(context),
          ),
        ),
      ),
    );

    return Row(children: children);
  }

  String _getPresetLabel(int duration) {
    switch (duration) {
      case 180:
        return 'Quick';
      case 300:
        return 'Balanced';
      case 420:
        return 'Marathon';
      default:
        return '${duration ~/ 60}m';
    }
  }

  String _formatDurationLabel(int seconds) {
    if (seconds <= 0) return '--';
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    if (remaining == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${remaining}s';
  }
}

class _TimerOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimerOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected
        ? AppConstants.backgroundDark
        : Colors.white.withOpacity(0.9);

    final Color textColor = isSelected
        ? AppConstants.backgroundDark
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.96,
        duration: AppConstants.shortAnimation,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppConstants.nigerianGold,
                      AppConstants.nigerianGold.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: isSelected ? null : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.6)
                  : Colors.white.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppConstants.nigerianGold.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24.w, color: iconColor),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isSelected
                      ? AppConstants.backgroundDark.withOpacity(0.7)
                      : Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomDurationDialog extends StatefulWidget {
  final int initialMinutes;

  const _CustomDurationDialog({required this.initialMinutes});

  @override
  State<_CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<_CustomDurationDialog> {
  late TextEditingController _minutesController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(
      text: widget.initialMinutes.clamp(1, 30).toString(),
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  void _submit() {
    final minutes = int.tryParse(_minutesController.text);
    if (minutes == null || minutes < 1 || minutes > 30) {
      setState(() {
        _errorText = 'Enter a value between 1 and 30 minutes';
      });
      return;
    }
    Navigator.of(context).pop(minutes * 60);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        'Custom Timer',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a duration between 1 and 30 minutes.',
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Minutes',
              labelStyle: const TextStyle(color: Colors.white70),
              errorText: _errorText,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppConstants.nigerianGold),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.nigerianGold,
            foregroundColor: AppConstants.backgroundDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
