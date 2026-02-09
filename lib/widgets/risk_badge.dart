import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/menu_item_result.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final bool large;

  const RiskBadge({super.key, required this.level, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(large ? 12 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _color, size: large ? 20 : 14),
          SizedBox(width: large ? 8 : 4),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.w600,
              fontSize: large ? 16 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color => switch (level) {
        RiskLevel.safe => AppTheme.safeColor,
        RiskLevel.caution => AppTheme.cautionColor,
        RiskLevel.danger => AppTheme.dangerColor,
      };

  Color get _bgColor => switch (level) {
        RiskLevel.safe => AppTheme.safeBg,
        RiskLevel.caution => AppTheme.cautionBg,
        RiskLevel.danger => AppTheme.dangerBg,
      };

  IconData get _icon => switch (level) {
        RiskLevel.safe => Icons.check_circle,
        RiskLevel.caution => Icons.warning_amber_rounded,
        RiskLevel.danger => Icons.dangerous,
      };

  String get _label => switch (level) {
        RiskLevel.safe => 'SAFE',
        RiskLevel.caution => 'CAUTION',
        RiskLevel.danger => 'DANGER',
      };
}
