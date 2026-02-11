import 'package:flutter_test/flutter_test.dart';
import 'package:safebite/models/allergen.dart';
import 'package:safebite/models/menu_item_result.dart';
import 'package:safebite/services/llm_service.dart';

void main() {
  late LlmService service;

  setUp(() {
    service = LlmService();
  });

  group('buildPrompt', () {
    test('includes all allergens with severity', () {
      final allergens = [
        Allergen(type: AllergenType.peanuts, severity: Severity.severe),
        Allergen(type: AllergenType.dairy, severity: Severity.mild),
      ];

      final prompt = service.buildPrompt('Menu text', allergens, null);

      expect(prompt, contains('Peanuts'));
      expect(prompt, contains('severity: Severe'));
      expect(prompt, contains('Dairy'));
      expect(prompt, contains('severity: Mild'));
    });

    test('includes cuisine hint when provided', () {
      final prompt = service.buildPrompt('Menu text', [], 'Thai');

      expect(prompt, contains('Detected cuisine type: Thai'));
    });

    test('says unknown cuisine when hint not provided', () {
      final prompt = service.buildPrompt('Menu text', [], null);

      expect(prompt, contains('Cuisine type: unknown'));
    });

    test('includes OCR text in prompt', () {
      final prompt = service.buildPrompt('Pad Thai 12.99\nGreen Curry 14.99', [], null);

      expect(prompt, contains('Pad Thai 12.99'));
      expect(prompt, contains('Green Curry 14.99'));
    });
  });

  group('parseResults', () {
    test('parses valid JSON array into MenuItemResult list', () {
      const json = '''[
        {
          "name": "Pad Thai",
          "risk_level": "danger",
          "confirmed_allergens": ["peanuts"],
          "explanation": "Contains peanuts"
        }
      ]''';

      final results = service.parseResults(json);
      expect(results.length, 1);
      expect(results.first.name, 'Pad Thai');
      expect(results.first.riskLevel, RiskLevel.danger);
      expect(results.first.confirmedAllergens, ['peanuts']);
    });

    test('strips markdown code fences before parsing', () {
      const json = '```json\n'
          '[{"name": "Salad", "risk_level": "safe", "explanation": "Safe"}]\n'
          '```';

      final results = service.parseResults(json);
      expect(results.length, 1);
      expect(results.first.name, 'Salad');
      expect(results.first.riskLevel, RiskLevel.safe);
    });

    test('falls back to regex extraction for wrapped JSON', () {
      const json = 'Here are the results:\n'
          '[{"name": "Soup", "risk_level": "safe", "explanation": "Safe"}]\n'
          'Some trailing text.';

      final results = service.parseResults(json);
      expect(results.length, 1);
      expect(results.first.name, 'Soup');
    });

    test('throws LlmException for completely invalid input', () {
      expect(
        () => service.parseResults('This is not JSON at all'),
        throwsA(isA<LlmException>()),
      );
    });

    test('handles confidence and substitution_suggestions fields', () {
      const json = '''[{
        "name": "Pad Thai",
        "risk_level": "danger",
        "confidence": 92,
        "confirmed_allergens": ["peanuts"],
        "explanation": "Contains peanuts",
        "substitution_suggestions": ["Ask for no peanuts"]
      }]''';

      final results = service.parseResults(json);
      expect(results.first.confidence, 92);
      expect(results.first.substitutionSuggestions, ['Ask for no peanuts']);
    });

    test('parses multiple items correctly', () {
      const json = '''[
        {"name": "A", "risk_level": "safe", "explanation": "Safe"},
        {"name": "B", "risk_level": "caution", "explanation": "Caution"},
        {"name": "C", "risk_level": "danger", "explanation": "Danger"}
      ]''';

      final results = service.parseResults(json);
      expect(results.length, 3);
      expect(results[0].riskLevel, RiskLevel.safe);
      expect(results[1].riskLevel, RiskLevel.caution);
      expect(results[2].riskLevel, RiskLevel.danger);
    });
  });

  test('analyzeMenu throws LlmException when API key is empty', () {
    expect(
      () => service.analyzeMenu(
        ocrText: 'test menu text',
        allergens: [Allergen(type: AllergenType.peanuts)],
      ),
      throwsA(isA<LlmException>()),
    );
  });
}
