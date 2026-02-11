import 'package:flutter/material.dart';
import '../models/menu_item_result.dart';
import '../models/scan_result.dart';
import '../core/theme.dart';

class ShareableResults extends StatelessWidget {
  final ScanResult result;

  const ShareableResults({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.shield, color: AppTheme.safeColor, size: 28),
              const SizedBox(width: 8),
              const Text('SafeBite', style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            result.restaurantName ?? 'Menu Scan',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Summary
          Text(
            '${result.safeCount} safe \u00b7 ${result.cautionCount} caution \u00b7 ${result.dangerCount} danger',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Divider(height: 24),

          // Items
          ...result.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: _riskColor(item.riskLevel),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item.name, style: const TextStyle(fontSize: 14))),
                Text(
                  item.riskLevel.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _riskColor(item.riskLevel),
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: 16),
          Text(
            'Scanned with SafeBite \u00b7 Always confirm with staff',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Color _riskColor(RiskLevel level) => switch (level) {
    RiskLevel.safe => AppTheme.safeColor,
    RiskLevel.caution => AppTheme.cautionColor,
    RiskLevel.danger => AppTheme.dangerColor,
  };
}
