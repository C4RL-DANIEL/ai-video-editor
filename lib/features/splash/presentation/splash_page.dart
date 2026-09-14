import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../presentation/auth_provider.dart';

/// Splash screen that checks auth state and navigates to the right place.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeLogo;
  late Animation<double> _fadeText;
  late Animation<double> _fadeTagline;
  late Animation<double> _fadeLoading;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeLogo = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _fadeText = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.6, curve: Curves.easeOut)),
    );
    _fadeTagline = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.45, 0.8, curve: Curves.easeOut)),
    );
    _fadeLoading = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateBasedOnAuth(AuthState authState) {
    if (_navigated || !mounted) return;

    if (authState == AuthState.unknown) return; // still loading

    _navigated = true;

    if (authState == AuthState.authenticated) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes and navigate when ready.
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      _navigateBasedOnAuth(next);
    });

    // Also check current state in case it already resolved.
    final authState = ref.watch(authStateProvider);
    // Defer navigation to after the first frame to avoid GoRouter conflicts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnAuth(authState);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isTablet = maxWidth > 600;
        final logoSize = isTablet ? 120.0 : 88.0;
        final titleSize = isTablet ? 42.0 : 32.0;
        final taglineSize = isTablet ? 18.0 : 14.0;

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0F),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 500 : maxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),
                      FadeTransition(
                        opacity: _fadeLogo,
                        child: Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(logoSize * 0.28),
                            border: Border.all(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              PhosphorIconsLight.filmStrip,
                              size: logoSize * 0.48,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 40 : 32),
                      FadeTransition(
                        opacity: _fadeText,
                        child: Text(
                          'AI Video Editor',
                          style: GoogleFonts.inter(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      FadeTransition(
                        opacity: _fadeTagline,
                        child: Text(
                          'Analyze  ·  Understand  ·  Create',
                          style: GoogleFonts.inter(
                            fontSize: taglineSize,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFA0A0A0),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      FadeTransition(
                        opacity: _fadeLoading,
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: const Color(0xFF3B82F6).withOpacity(0.8),
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 48 : 36),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
