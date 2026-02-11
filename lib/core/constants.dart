abstract class Constants {
  // Replace with your actual API key before running
  static const anthropicApiKey = String.fromEnvironment(
    'ANTHROPIC_API_KEY',
    defaultValue: '',
  );

  static const anthropicBaseUrl = 'https://api.anthropic.com/v1/messages';
  static const anthropicVersion = '2023-06-01';
  static const llmModel = 'claude-sonnet-4-5-20250929';
  static const llmMaxTokens = 4096;
  static const llmFallbackModel = 'claude-haiku-4-5-20251001';
  static const llmFallbackMaxTokens = 4096;
  static const llmTimeoutSeconds = 45;
  static const llmFallbackTimeoutSeconds = 30;

  static const appName = 'SafeBite';
  static const disclaimerText =
      'SafeBite provides AI-generated guidance only. '
      'Always confirm allergen information with restaurant staff. '
      'This app is not a substitute for professional medical advice.';
}
