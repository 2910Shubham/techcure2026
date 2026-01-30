import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'splashScreen.dart';
import 'web_view_screen.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const VirAshatSplashScreen(),
    ),
    GoRoute(
      path: '/webview',
      builder: (context, state) =>
          const WebViewScreen(url: 'https://techcure.bitbrains.site/'),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Virasat TechCure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

