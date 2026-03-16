import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'providers/auth_provider.dart' as app;
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PinkyShopApp());
}

class PinkyShopApp extends StatelessWidget {
  const PinkyShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => app.AuthProvider(),
      child: MaterialApp(
        title: 'Pinky Shop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const _AuthGate(),
        );
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const _PrivateRoute(child: HomeScreen()),
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const _PublicRoute(child: LoginScreen()),
        );
      case '/signup':
        return MaterialPageRoute(
          builder: (_) => const _PublicRoute(child: SignupScreen()),
        );
      case '/cart':
        return MaterialPageRoute(
          builder: (_) => const _PrivateRoute(child: CartScreen()),
        );
      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const _PrivateRoute(child: ProfileScreen()),
        );
      case '/chat':
        return MaterialPageRoute(
          builder: (_) => const _PrivateRoute(child: ChatScreen()),
        );
      case '/admin':
        return MaterialPageRoute(
          builder: (_) => const _AdminRoute(child: AdminDashboard()),
        );
      case '/product':
        final productId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => _PrivateRoute(
            child: ProductDetailScreen(productId: productId),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const _AuthGate(),
        );
    }
  }
}

/// Initial gate — redirects based on auth state
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app.AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_rounded,
                  color: AppTheme.primary, size: 56),
              SizedBox(height: 20),
              CircularProgressIndicator(color: AppTheme.primary),
            ],
          ),
        ),
      );
    }

    if (auth.isLoggedIn) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

/// Redirects unauthenticated users to login
class _PrivateRoute extends StatelessWidget {
  final Widget child;
  const _PrivateRoute({required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app.AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}

/// Redirects non-admin users to home
class _AdminRoute extends StatelessWidget {
  final Widget child;
  const _AdminRoute({required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app.AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (!auth.isLoggedIn || !auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}

/// Redirects already-logged-in users to home
class _PublicRoute extends StatelessWidget {
  final Widget child;
  const _PublicRoute({required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<app.AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}
