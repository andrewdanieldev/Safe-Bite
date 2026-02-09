import 'package:flutter_test/flutter_test.dart';
import 'package:safebite/models/allergen.dart';
import 'package:safebite/models/menu_item_result.dart';

void main() {
  test('Allergen has correct display name', () {
    final allergen = Allergen(type: AllergenType.peanuts);
    expect(allergen.displayName, 'Peanuts');
    expect(allergen.emoji, '🥜');
  });

  test('Custom allergen uses custom name', () {
    final allergen = Allergen(
      type: AllergenType.custom,
      customName: 'Mango',
    );
    expect(allergen.displayName, 'Mango');
  });

  test('RiskLevel parses from string', () {
    expect(RiskLevel.fromString('safe'), RiskLevel.safe);
    expect(RiskLevel.fromString('danger'), RiskLevel.danger);
    expect(RiskLevel.fromString('CAUTION'), RiskLevel.caution);
    expect(RiskLevel.fromString('unknown'), RiskLevel.caution);
  });

  test('MenuItemResult deserializes from JSON', () {
    final json = {
      'name': 'Pad Thai',
      'description': 'Rice noodles with shrimp',
      'risk_level': 'danger',
      'confirmed_allergens': ['peanuts', 'shellfish'],
      'likely_allergens': ['fish', 'soy'],
      'possible_allergens': ['eggs'],
      'explanation': 'Contains peanuts and shrimp.',
      'waiter_question': 'Can this be made without peanuts?',
    };

    final item = MenuItemResult.fromJson(json);
    expect(item.name, 'Pad Thai');
    expect(item.riskLevel, RiskLevel.danger);
    expect(item.confirmedAllergens, ['peanuts', 'shellfish']);
    expect(item.allAllergens.length, 5);
  });
}
