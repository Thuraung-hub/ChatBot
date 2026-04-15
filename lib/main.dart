import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'config/app_config.dart';
import 'config/app_constants.dart';
import 'services/auth_service.dart';
import 'utils/page_routes.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/offline_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');

    // Set environment (change based on build configuration)
    Config.setEnvironment(
        Environment.production); // For Firebase Hosting web deployment

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!kIsWeb) {
      try {
        await FirebasePerformance.instance
            .setPerformanceCollectionEnabled(Config.enableFirebasePerformance);
      } on MissingPluginException {
        debugPrint(
            'Firebase Performance plugin is unavailable on this platform.');
      } catch (error) {
        debugPrint('Firebase Performance setup warning: $error');
      }
    }

    final dsn = Config.sentryDsn;
    if (dsn != null) {
      await SentryFlutter.init(
        (options) {
          options.dsn = dsn;
          options.tracesSampleRate = 0.2;
        },
        appRunner: () => runApp(const PinkyShopApp()),
      );
      return;
    }

    runApp(const PinkyShopApp());
  } catch (error) {
    runApp(BootstrapErrorApp(errorMessage: error.toString()));
  }
}

class BootstrapErrorApp extends StatelessWidget {
  final String errorMessage;

  const BootstrapErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppTheme.screenBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'App failed to start',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please refresh the page. If the issue continues, check environment configuration and Firebase setup.',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: SelectableText(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PinkyShopApp extends StatefulWidget {
  const PinkyShopApp({super.key});

  @override
  State<PinkyShopApp> createState() => _PinkyShopAppState();
}

class _PinkyShopAppState extends State<PinkyShopApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _refreshConnectivity();
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _refreshConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _onConnectivityChanged(results);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOffline = _isOffline;
    final isOffline =
        results.isEmpty || results.contains(ConnectivityResult.none);

    if (wasOffline != isOffline && mounted) {
      setState(() => _isOffline = isOffline);
    } else {
      _isOffline = isOffline;
    }

    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    if (!isOffline && wasOffline) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Connection restored'),
            backgroundColor: AppTheme.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        scaffoldMessengerKey: _scaffoldMessengerKey,
        title: 'Pinky Shop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: AppConstants.rootRoute,
        onGenerateRoute: _generateRoute,
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();

          final mediaQuery = MediaQuery.of(context);
          final width = mediaQuery.size.width;
          final minScale = width < 360 ? 0.92 : 1.0;
          final maxScale = width >= 1200 ? 1.2 : 1.1;

          final responsiveChild = MediaQuery(
            data: mediaQuery.copyWith(
              textScaler:
                  mediaQuery.textScaler.clamp(minScaleFactor: minScale, maxScaleFactor: maxScale),
            ),
            child: child,
          );

          if (!_isOffline) return responsiveChild;

          return PopScope(
            canPop: false,
            child: Stack(
              children: [
                responsiveChild,
                Positioned.fill(
                  child: OfflineScreen(onRetry: _refreshConnectivity),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.rootRoute:
        return AppPageRoute.fade(const _AuthGate());
      case AppConstants.homeRoute:
        return AppPageRoute.slideFromRight(
          const _PrivateRoute(child: HomeScreen()),
        );
      case AppConstants.loginRoute:
        return AppPageRoute.fade(const _PublicRoute(child: LoginScreen()));
      case AppConstants.signupRoute:
        return AppPageRoute.slideFromRight(
          const _PublicRoute(child: RegistrationScreen()),
        );
      case AppConstants.cartRoute:
        return AppPageRoute.slideFromRight(
          const _PrivateRoute(child: CartScreen()),
        );
      case AppConstants.profileRoute:
        return AppPageRoute.slideFromRight(
          const _PrivateRoute(child: ProfileScreen()),
        );
      case AppConstants.chatRoute:
        return AppPageRoute.slideFromBottom(
          const _PrivateRoute(child: ChatScreen()),
        );
      case AppConstants.adminRoute:
        return AppPageRoute.slideFromRight(
          const _AdminRoute(child: AdminDashboard()),
        );
      case AppConstants.productRoute:
        final productId = settings.arguments as String? ?? '';
        return AppPageRoute.slideFromRight(
          _PrivateRoute(
            child: ProductDetailScreen(productId: productId),
          ),
        );
      default:
        return AppPageRoute.fade(const _AuthGate());
    }
  }
}

/// Initial gate — redirects based on auth state
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

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
    final auth = context.watch<AuthService>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, Routes.login.path);
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
    final auth = context.watch<AuthService>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (!auth.isLoggedIn || !auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, Routes.home.path);
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
    final auth = context.watch<AuthService>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, Routes.home.path);
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}
