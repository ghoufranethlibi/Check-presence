import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
import 'services/auth_service.dart';
import 'services/attendance_service.dart';
import 'services/notif_service.dart';
import 'utils/app_theme.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/employee/employee_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await NotifService.instance.init();
  if (!Platform.isWindows) {
    await Permission.camera.request();
  }
  final settings = SettingsProvider();
  await settings.loadSettings();
  final auth = AuthService();
  await auth.restoreSession();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider(create: (_) => AttendanceService()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthService>();
    return Directionality(
      textDirection:
          settings.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: MaterialApp(
        title: 'Smart Badge Scanner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.themeMode,
        locale: settings.locale,
        home: const LoginScreen(),
      ),
    );
  }

}