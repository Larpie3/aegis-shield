import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'screens/about_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

class AegisApp extends StatelessWidget {
  const AegisApp({super.key, required this.showOnboarding});

  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis Ad-Shield',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/about':
            page = const AboutScreen();
            break;
          case '/':
          default:
            page = showOnboarding ? const OnboardingScreen() : const HomeScreen();
            break;
        }

        return PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              fillColor: Colors.transparent,
              child: child,
            );
          },
        );
      },
    );
  }
}
