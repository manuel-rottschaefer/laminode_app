import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  final String backendBaseUrl;

  const AppConfig({required this.backendBaseUrl});

  factory AppConfig.development() {
    return const AppConfig(backendBaseUrl: 'http://localhost:8000/api/v1/');
  }

  // You can add more environments or loading from .env/json later
}

final appConfigProvider = Provider<AppConfig>((ref) {
  // Logic to determine environment could go here
  return AppConfig.development();
});
