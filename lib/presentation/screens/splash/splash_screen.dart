import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notes_app/presentation/screens/auth/login_screen.dart';
import 'package:notes_app/presentation/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

//Splash screen to handle initial app loading and authentication check
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthState();
  }

  //Initialize splash screen animations with app constants
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.splashDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  //Check authentication state and navigate accordingly
  Future<void> _checkAuthState() async {
    try {
      // Add minimum splash duration for better UX
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();

      // Check if user is authenticated
      final isAuthenticated = authProvider.checkAuthState();

      if (!mounted) return;

      if (isAuthenticated) {
        // User is authenticated, navigate to home screen
        _navigateToHome();
      } else {
        // User is not authenticated, navigate to login screen
        _navigateToLogin();
      }
    } catch (e) {

      if (!mounted) return;

      // On error, navigate to login screen
      _navigateToLogin();
    }
  }

  //Navigate to home screen replacing current route
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernHomeScreen(),
      ),
    );
  }

  //Navigate to login screen replacing current route
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.primary10,
              Theme.of(context).scaffoldBackgroundColor,
              context.secondary05,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo container with gradient
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.extraLargeRadius.r,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: context.primary30,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/images/logo.png",
                            width: 80.w,
                            height: 80.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(height: AppConstants.extraLargePadding.h),

                      // App name with styling
                      Text(
                        AppConstants.appName.split(' ').first,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),

                      SizedBox(height: AppConstants.smallPadding.h),

                      // App tagline
                      Text(
                        AppConstants.appDescription,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: context.onSurface70,
                              letterSpacing: 0.2,
                            ),
                      ),

                      SizedBox(height: 60.h),

                      // Loading indicator with app colors
                      SizedBox(
                        width: 40.w,
                        height: 40.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
