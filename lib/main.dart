import 'package:connect_b/app/router/app_router.dart';
import 'package:connect_b/app/theme/app_theme.dart';
import 'package:connect_b/core/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw Exception('Missing SUPABASE_URL in .env');
  }
  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw Exception('Missing SUPABASE_ANON_KEY in .env');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(
    ProviderScope(
      child: ConnectBApp(
        hasSession: Supabase.instance.client.auth.currentSession != null,
      ),
    ),
  );
}

class ConnectBApp extends StatelessWidget {
  const ConnectBApp({required this.hasSession, super.key});

  final bool hasSession;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BAUST Connect',
      theme: AppTheme.light,
      navigatorKey: NavigationService.instance.navigatorKey,
      initialRoute: hasSession ? AppRoutes.home : AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
