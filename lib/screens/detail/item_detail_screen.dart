import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/menu_item_result.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/risk_badge.dart';

class ItemDetailScreen extends ConsumerWidget {
  final int itemIndex;

  const ItemDetailScreen({super.key, required this.itemIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final items = scanState.result?.items ?? [];
    final theme = Theme.of(context);

    if (itemIndex >= items.length) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Item not found.')),
      );
    }

    final item = items[itemIndex];

    if (item.riskLevel == RiskLevel.danger) {
      HapticFeedback.heavyImpact();
    } else if (item.riskLevel == RiskLevel.caution) {
      HapticFeedback.mediumImpact();
    }

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Risk badge
            Center(child: RiskBadge(level: item.riskLevel, large: true)),
            if (item.confidence > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 16, color: _confidenceColor(item.confidence)),
                  const SizedBox(width: 4),
                  Text(
                    '${item.confidence}% confidence',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _confidenceColor(item.confidence),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else ...[
              const SizedBox(height: 20),
            ],

            // Item name and description
            Hero(
              tag: 'item_$itemIndex',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  item.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Allergen sections
            if (item.confirmedAllergens.isNotEmpty)
              _AllergenSection(
                title: 'Confirmed Allergens',
                subtitle: 'Explicitly listed on the menu',
                allergens: item.confirmedAllergens,
                color: AppTheme.dangerColor,
                bgColor: AppTheme.dangerBg,
                icon: Icons.error,
              ),
            if (item.likelyAllergens.isNotEmpty)
              _AllergenSection(
                title: 'Likely Allergens',
                subtitle: 'Standard ingredients for this dish type',
                allergens: item.likelyAllergens,
                color: AppTheme.cautionColor,
                bgColor: AppTheme.cautionBg,
                icon: Icons.warning_amber,
              ),
            if (item.possibleAllergens.isNotEmpty)
              _AllergenSection(
                title: 'Possible (Cross-contamination)',
                subtitle: 'Risks based on cuisine/kitchen type',
                allergens: item.possibleAllergens,
                color: const Color(0xFF5D4037),
                bgColor: const Color(0xFFEFEBE9),
                icon: Icons.help_outline,
              ),

            // Explanation
            const SizedBox(height: 16),
            _DetailCard(
              title: 'Why this rating?',
              icon: Icons.info_outline,
              child: Text(
                item.explanation,
                style: theme.textTheme.bodyMedium,
              ),
            ),

            // Waiter question
            if (item.waiterQuestion.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailCard(
                title: 'Ask Your Waiter',
                icon: Icons.record_voice_over,
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy to clipboard',
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: item.waiterQuestion),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                child: Text(
                  item.waiterQuestion,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            // Substitution suggestions
            if (item.substitutionSuggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: AppTheme.safeBg,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 20, color: AppTheme.safeColor),
                          const SizedBox(width: 8),
                          Text(
                            'How to Make It Safer',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.safeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...item.substitutionSuggestions.map((suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('  \u2022  '),
                            Expanded(child: Text(suggestion, style: theme.textTheme.bodyMedium)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],

            // Disclaimer
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Constants.disclaimerText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _confidenceColor(int confidence) {
    if (confidence >= 90) return AppTheme.safeColor;
    if (confidence >= 70) return AppTheme.cautionColor;
    return AppTheme.dangerColor;
  }
}

class _AllergenSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> allergens;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _AllergenSection({
    required this.title,
    required this.subtitle,
    required this.allergens,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: allergens
                .map((a) => Chip(
                      label: Text(a),
                      backgroundColor: bgColor,
                      labelStyle: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
