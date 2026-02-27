// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/chat_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const StitchShopApp());
}

class StitchShopApp extends StatelessWidget {
  const StitchShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (_, user, __) => MaterialApp(
          title: 'Stitch Shop',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          // Auth-gated routing: show login until user is authenticated
          home: user.isLoggedIn
              ? const MainShell()
              : const AuthScreen(),
        ),
      ),
    );
  }
}
