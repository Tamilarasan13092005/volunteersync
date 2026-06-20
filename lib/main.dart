import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/volunteers_provider.dart';
import 'providers/events_provider.dart';
import 'providers/chat_provider.dart';
import 'routes/app_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mspciorhvkjxsfllnvwn.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zcGNpb3JodmtqeHNmbGxudnduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxMjA4ODAsImV4cCI6MjA5NTY5Njg4MH0.1TCj_TOGpYQJeFc4n6SodqMzd6ZqKTTeJ5YDBVc9RUQ',
  );

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );

  // Lock to portrait on phones, allow all on tablets
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Dark system UI overlay
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const VolunteerSyncApp());
}

class VolunteerSyncApp extends StatelessWidget {
  const VolunteerSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => VolunteersProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(context);
          return MaterialApp.router(
            title: 'VolunteerSync',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
