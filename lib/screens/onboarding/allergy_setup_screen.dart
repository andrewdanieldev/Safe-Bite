import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/allergen.dart';
import '../../providers/allergy_profile_provider.dart';

class AllergySetupScreen extends ConsumerStatefulWidget {
  const AllergySetupScreen({super.key});

  @override
  ConsumerState<AllergySetupScreen> createState() => _AllergySetupScreenState();
}

class _AllergySetupScreenState extends ConsumerState<AllergySetupScreen> {
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allergens = ref.watch(allergyProfileProvider);
    final notifier = ref.read(allergyProfileProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                'What are you\nallergic to?',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select all that apply. You can always change this later.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAllergenGrid(notifier, allergens),
                      const SizedBox(height: 24),
                      _buildCustomAllergenInput(notifier),
                      if (allergens.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSelectedSection(allergens, notifier, theme),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomBar(allergens, theme),
    );
  }

  Widget _buildAllergenGrid(
    AllergyProfileNotifier notifier,
    List<Allergen> selected,
  ) {
    // Exclude 'custom' from the grid — it has its own input field
    final types =
        AllergenType.values.where((t) => t != AllergenType.custom).toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: types.map((type) {
        final isSelected = notifier.isSelected(type);
        return FilterChip(
          label: Text('${type.emoji}  ${type.label}'),
          selected: isSelected,
          onSelected: (_) => notifier.toggleAllergen(type),
          selectedColor: AppTheme.dangerBg,
          checkmarkColor: AppTheme.dangerColor,
          showCheckmark: true,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildCustomAllergenInput(AllergyProfileNotifier notifier) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _customController,
            decoration: InputDecoration(
              hintText: 'Add custom allergen...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => _addCustom(notifier),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: () => _addCustom(notifier),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _addCustom(AllergyProfileNotifier notifier) {
    if (_customController.text.trim().isEmpty) return;
    notifier.addCustomAllergen(_customController.text);
    _customController.clear();
  }

  Widget _buildSelectedSection(
    List<Allergen> allergens,
    AllergyProfileNotifier notifier,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your allergens',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...allergens.map(
          (allergen) => _AllergenSeverityTile(
            allergen: allergen,
            onSeverityChanged: (severity) =>
                notifier.updateSeverity(allergen, severity),
            onRemove: () => notifier.removeAllergen(allergen),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(List<Allergen> allergens, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: allergens.isEmpty ? null : () => context.go('/scan'),
          child: Text(
            allergens.isEmpty
                ? 'Select at least one allergen'
                : 'Continue (${allergens.length})',
          ),
        ),
      ),
    );
  }
}

class _AllergenSeverityTile extends StatelessWidget {
  final Allergen allergen;
  final ValueChanged<Severity> onSeverityChanged;
  final VoidCallback onRemove;

  const _AllergenSeverityTile({
    required this.allergen,
    required this.onSeverityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(allergen.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allergen.displayName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<Severity>(
                    segments: Severity.values
                        .map((s) => ButtonSegment(
                              value: s,
                              label: Text(
                                s.label,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ))
                        .toList(),
                    selected: {allergen.severity},
                    onSelectionChanged: (set) => onSeverityChanged(set.first),
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),

                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
