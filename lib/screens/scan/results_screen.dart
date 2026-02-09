import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/menu_item_result.dart';
import '../../models/scan_result.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/risk_badge.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  RiskLevel? _filter;

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final result = scanState.result;
    final theme = Theme.of(context);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const Center(child: Text('No scan results available.')),
      );
    }

    final items = result.items;
    final filtered = _filter == null
        ? items
        : items.where((i) => i.riskLevel == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(result.restaurantName ?? 'Scan Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(scanProvider.notifier).reset();
            context.go('/scan');
          },
        ),
      ),
      body: Column(
        children: [
          _buildSummaryBar(result, theme),
          _buildFilterChips(theme),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No items match this filter.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final originalIndex = items.indexOf(item);
                      return _MenuItemCard(
                        item: item,
                        onTap: () =>
                            context.push('/detail/$originalIndex'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(scanProvider.notifier).reset();
          context.go('/scan');
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Another'),
      ),
    );
  }

  Widget _buildSummaryBar(ScanResult result, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SummaryChip(
            count: result.safeCount,
            label: 'safe',
            color: AppTheme.safeColor,
          ),
          const SizedBox(width: 16),
          _SummaryChip(
            count: result.cautionCount,
            label: 'caution',
            color: AppTheme.cautionColor,
          ),
          const SizedBox(width: 16),
          _SummaryChip(
            count: result.dangerCount,
            label: 'danger',
            color: AppTheme.dangerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildChip('All', null),
          const SizedBox(width: 8),
          _buildChip('Safe', RiskLevel.safe),
          const SizedBox(width: 8),
          _buildChip('Caution', RiskLevel.caution),
          const SizedBox(width: 8),
          _buildChip('Danger', RiskLevel.danger),
        ],
      ),
    );
  }

  Widget _buildChip(String label, RiskLevel? level) {
    final selected = _filter == level;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = level),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemResult item;
  final VoidCallback onTap;

  const _MenuItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = switch (item.riskLevel) {
      RiskLevel.safe => AppTheme.safeColor,
      RiskLevel.caution => AppTheme.cautionColor,
      RiskLevel.danger => AppTheme.dangerColor,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: riskColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          RiskBadge(level: item.riskLevel),
                        ],
                      ),
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (item.allAllergens.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: item.allAllergens
                              .map((a) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: riskColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      a,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: riskColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
