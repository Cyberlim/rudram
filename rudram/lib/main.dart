import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/globals.dart';
import 'widgets/cart_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/rooms_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/wallet_provider.dart';
import 'services/firestore_service.dart';
import 'utils/lenis_scroll_physics.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AppAuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) => cart!..updateUid(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, OrdersProvider>(
          create: (_) => OrdersProvider(),
          update: (_, auth, orders) => orders!..updateUid(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(),
          update: (_, auth, wishlist) => wishlist!..updateUid(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, WalletProvider>(
          create: (_) => WalletProvider(),
          update: (_, auth, wallet) => wallet!..updateUid(auth.user?.uid),
        ),
        ChangeNotifierProvider(create: (_) => RoomsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: Globals.navigatorKey,
          title: 'Rudram — Luxury Jewellery',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          scrollBehavior: const LenisScrollBehavior(),
          builder: (context, child) {
            return Scaffold(
              key: Globals.appScaffoldKey,
              endDrawer: const CartSidebar(),
              body: child,
            );
          },
          home: const AuthGate(),
        );
      },
    );
  }
}

/// Auth gate: shows the main app if authenticated, otherwise the auth screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.initial:
            // Splash / loading state
            return const Scaffold(
              backgroundColor: Color(0xFF1A0A00),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF37A20),
                ),
              ),
            );

          case AuthStatus.authenticated:
            return const HomeScreen();

          case AuthStatus.unauthenticated:
          case AuthStatus.error:
          default:
            return const AuthScreen();
        }
      },
    );
  }
}
