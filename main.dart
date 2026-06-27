import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/home/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait (player changes this when opened)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Init API client
  ApiClient.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkAuth(),
      child: const CinemaApp(),
    ),
  );
}

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سينما بوكس',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainApp(),
      routes: {
        '/search': (_) => const _SearchPage(),
      },
    );
  }
}

// Wrapper to use as named route
class _SearchPage extends StatelessWidget {
  const _SearchPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Search')),
    );
  }
}
