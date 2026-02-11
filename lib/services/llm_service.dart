import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/allergen.dart';
import '../models/menu_item_result.dart';

class LlmException implements Exception {
  final String message;
  LlmException(this.message);

  @override
  String toString() => 'LlmException: $message';
}

class StreamingUpdate {
  final String partialText;
  final bool isComplete;
  final List<MenuItemResult>? items;
  final String? fallbackMessage;

  const StreamingUpdate({
    required this.partialText,
    required this.isComplete,
    this.items,
    this.fallbackMessage,
  });
}

class LlmService {
  Future<List<MenuItemResult>> analyzeMenu({
    required String ocrText,
    required List<Allergen> allergens,
    String? cuisineHint,
  }) async {
    if (Constants.anthropicApiKey.isEmpty) {
      throw LlmException('API key not configured. '
          'Pass --dart-define=ANTHROPIC_API_KEY=your_key when running.');
    }

    final prompt = buildPrompt(ocrText, allergens, cuisineHint);

    final response = await http
        .post(
          Uri.parse(Constants.anthropicBaseUrl),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': Constants.anthropicApiKey,
            'anthropic-version': Constants.anthropicVersion,
          },
          body: jsonEncode({
            'model': Constants.llmModel,
            'max_tokens': Constants.llmMaxTokens,
            'messages': [
              {'role': 'user', 'content': prompt},
            ],
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw LlmException('API error ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final content = body['content'] as List;
    final text = content.first['text'] as String;

    return parseResults(text);
  }

  @visibleForTesting
  String buildPrompt(
    String ocrText,
    List<Allergen> allergens,
    String? cuisineHint,
  ) {
    final allergenList = allergens
        .map((a) => '- ${a.displayName} (severity: ${a.severity.label})')
        .join('\n');

    final cuisineLine = cuisineHint != null
        ? '\nDetected cuisine type: $cuisineHint'
        : '\nCuisine type: unknown (infer from menu items)';

    return '''You are a food allergy safety expert. I will give you:
1. A user's allergen profile
2. Raw text extracted from a restaurant menu via OCR

Your job is to analyze EVERY menu item and assess its risk for this specific user.

USER'S ALLERGENS:
$allergenList

MENU TEXT (OCR-extracted, may contain errors):
"""
$ocrText
"""
$cuisineLine

For EACH menu item you can identify, return a JSON array with this structure:

[
  {
    "name": "Dish Name",
    "description": "menu description if visible, or null",
    "risk_level": "safe|caution|danger",
    "confidence": 82,
    "confirmed_allergens": ["allergens explicitly mentioned in menu text"],
    "likely_allergens": ["allergens that are standard ingredients for this dish type, even if not listed"],
    "possible_allergens": ["cross-contamination risks based on cuisine/kitchen type"],
    "explanation": "Clear explanation of why this risk level was assigned",
    "waiter_question": "Specific question(s) to ask the waiter about this dish",
    "substitution_suggestions": ["Ask for no peanuts", "Request tamari instead of soy sauce"]
  }
]

RULES:
- Be CONSERVATIVE. When in doubt, flag it as "caution" rather than "safe".
- Infer ingredients based on cuisine type and common preparation methods.
- Consider cross-contamination risks based on kitchen type.
- If OCR text is garbled, do your best to interpret dish names.
- The "explanation" should be clear enough for a non-expert to understand.
- The "waiter_question" should be specific and actionable.
- Only flag allergens that are in the user's allergen list above.
- Include a "confidence" field (0-100) indicating how confident you are in the risk assessment. 90+ means text explicitly confirms allergens. 60-89 means inferred from dish type. Below 60 means uncertain.
- Include "substitution_suggestions" — a list of specific modifications the user could request to make the dish safer. If the dish is already safe, return an empty list.
- Return ONLY valid JSON. No markdown code fences, no commentary outside the JSON array.''';
  }

  @visibleForTesting
  List<MenuItemResult> parseResults(String text) {
    // Strip markdown code fences if present
    var cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```\w*\n?'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
      cleaned = cleaned.trim();
    }

    try {
      final list = jsonDecode(cleaned) as List;
      return list
          .map((e) => MenuItemResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Try to extract JSON array from the response
      final match = RegExp(r'\[[\s\S]*\]').firstMatch(cleaned);
      if (match != null) {
        final list = jsonDecode(match.group(0)!) as List;
        return list
            .map((e) => MenuItemResult.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw LlmException('Failed to parse response: $e');
    }
  }

  Stream<StreamingUpdate> analyzeMenuStreaming({
    required String ocrText,
    required List<Allergen> allergens,
    String? cuisineHint,
  }) async* {
    final prompt = buildPrompt(ocrText, allergens, cuisineHint);
    final model = Constants.llmModel;

    yield* _streamFromModel(prompt, model, Constants.llmTimeoutSeconds);
  }

  Stream<StreamingUpdate> _streamFromModel(
    String prompt,
    String model,
    int timeoutSeconds,
  ) async* {
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse(Constants.anthropicBaseUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'x-api-key': Constants.anthropicApiKey,
        'anthropic-version': Constants.anthropicVersion,
      });
      request.body = jsonEncode({
        'model': model,
        'max_tokens': Constants.llmMaxTokens,
        'stream': true,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      });

      final response = await client.send(request)
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode != 200) {
        throw LlmException('API error: ${response.statusCode}');
      }

      final buffer = StringBuffer();
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        // Parse SSE: each event is "event: type\ndata: json\n\n"
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') continue;
            try {
              final event = jsonDecode(data) as Map<String, dynamic>;
              if (event['type'] == 'content_block_delta') {
                final delta = event['delta']?['text'] ?? '';
                buffer.write(delta);
                yield StreamingUpdate(
                  partialText: buffer.toString(),
                  isComplete: false,
                );
              } else if (event['type'] == 'message_stop') {
                yield StreamingUpdate(
                  partialText: buffer.toString(),
                  isComplete: true,
                  items: parseResults(buffer.toString()),
                );
              }
            } catch (_) {
              // Skip malformed SSE lines
            }
          }
        }
      }
    } finally {
      client.close();
    }
  }

  /// Tries Sonnet first, falls back to Haiku on failure.
  Stream<StreamingUpdate> analyzeMenuWithFallback({
    required String ocrText,
    required List<Allergen> allergens,
    String? cuisineHint,
  }) async* {
    final prompt = buildPrompt(ocrText, allergens, cuisineHint);

    try {
      yield* _streamFromModel(
        prompt,
        Constants.llmModel,
        Constants.llmTimeoutSeconds,
      );
    } catch (e) {
      // Sonnet failed — retry with Haiku
      yield StreamingUpdate(
        partialText: '',
        isComplete: false,
        fallbackMessage: 'Retrying with faster model...',
      );
      yield* _streamFromModel(
        prompt,
        Constants.llmFallbackModel,
        Constants.llmFallbackTimeoutSeconds,
      );
    }
  }
}
