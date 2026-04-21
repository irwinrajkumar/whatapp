import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatapp/features/auth/welcome_screen.dart';
import 'package:whatapp/main.dart';
import 'package:whatapp/state/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final navigator = Navigator.of(context);
    Future.microtask(() => _start(navigator));
  }

  Future<void> _start(NavigatorState navigator) async {
    final session = ref.read(appSessionProvider);
    if (!session.isReady) {
      await session.initialize();
    }
    if (!mounted) return;

    final destination =
        session.isLoggedIn ? const MainScreen() : const WelcomeScreen();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

