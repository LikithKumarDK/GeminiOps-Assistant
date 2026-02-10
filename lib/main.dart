import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: AIAssistantApp()));
}

class AIAssistantApp extends StatelessWidget {
  const AIAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeminiOps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
