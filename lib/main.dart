import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme_dark.dart';
import 'core/theme/app_theme_light.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration du statut bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // Verrouillage en mode portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: SafeVaultApp(),
    ),
  );
}

class SafeVaultApp extends ConsumerWidget {
  const SafeVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Thèmes
      theme: AppThemeLight.theme,
      darkTheme: AppThemeDark.theme,
      themeMode: themeMode, // Dynamique avec le provider
      
      // Écran initial
      home: const SplashScreen(),
    );
  }
}

