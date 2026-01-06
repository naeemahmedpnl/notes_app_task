import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notes_app/core/utils/app_snackbar.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  // Auth provider reference and listener for proper cleanup
  late AuthProvider _authProvider;
  VoidCallback? _authListener;

  @override
  void initState() {
    super.initState();
    // Setup auth listener after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAuthListener();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store auth provider reference for proper cleanup
    _authProvider = context.read<AuthProvider>();
  }

  //Setup authentication state listener with proper error handling
  void _setupAuthListener() {
    _authListener = () {
      if (!mounted) return;

      if (_authProvider.isAuthenticated) {
        _navigateToHomeScreen();
      } else if (_authProvider.authState == AuthState.error) {
        context.showError(
            _authProvider.errorMessage ?? AppConstants.authErrorMessage);
      }
    };

    // Add listener to auth provider
    _authProvider.addListener(_authListener!);
  }

  //Navigate to home screen replacing current route
  void _navigateToHomeScreen() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernHomeScreen(),
      ),
    );
  }

  //Navigate to signup screen
  void _navigateToSignupScreen() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  //Handle login form submission with proper validation
  Future<void> _handleLogin() async {
    if (!mounted) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Hide keyboard before processing
    FocusScope.of(context).unfocus();

    try {
      await _authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        context.showError('Login failed: $e');
      }
    }
  }

  //Show forgot password dialog with email validation
  void _showForgotPasswordDialog() {
    if (!mounted) return;

    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppConstants.resetPasswordTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address to receive a password reset link.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: emailController,
                labelText: AppConstants.emailLabel,
                prefixIcon: CupertinoIcons.mail,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppConstants.cancelLabel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();

                if (mounted) {
                  try {
                    await _authProvider.sendPasswordResetEmail(
                      emailController.text.trim(),
                    );

                    if (mounted) {
                      context.showSuccess('Password reset email sent!');
                    }
                  } catch (e) {
                    if (mounted) {
                      context.showError('Failed to send reset email: $e');
                    }
                  }
                }
              }
            },
            child: Text(AppConstants.sendLabel),
          ),
        ],
      ),
    ).then((_) {
      // Dispose email controller when dialog closes
      emailController.dispose();
    });
  }

  @override
  void dispose() {
    // Remove auth listener with proper error handling
    if (_authListener != null) {
      try {
        _authProvider.removeListener(_authListener!);
      } catch (e) {
        log('LoginScreen: Error removing auth listener: $e');
      }
    }

    // Dispose text controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ResponsiveWidget(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
        ),
      ),
    );
  }

  //Build responsive mobile layout
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20.h),
          _buildHeader(),
          SizedBox(height: 20.h),
          _buildLoginForm(),
          SizedBox(height: 16.h),
          _buildSignupPrompt(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  //Build responsive tablet layout
  Widget _buildTabletLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: context.responsivePadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: 24.h),
              _buildLoginForm(),
              SizedBox(height: 20.h),
              _buildSignupPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  //Build screen header with app branding
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (context.isMobile || context.isTablet) ...[
          Icon(
            CupertinoIcons.doc_text,
            size: ResponsiveHelper.getResponsiveValue(
              context,
              mobile: 60.w,
              tablet: 70.w,
            ),
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
        ],
        Text(
          AppConstants.signInLabel,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 8.h),
        Text(
          'Welcome back! Please sign in to continue.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  //Build login form with email and password fields
  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email field
              CustomTextField(
                controller: _emailController,
                labelText: AppConstants.emailLabel,
                prefixIcon: CupertinoIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.validateEmail,
                enabled: !authProvider.isLoading,
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                controller: _passwordController,
                labelText: AppConstants.passwordLabel,
                prefixIcon: CupertinoIcons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                  ),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    }
                  },
                ),
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done,
                validator: Validators.validatePassword,
                enabled: !authProvider.isLoading,
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: authProvider.isLoading
                            ? null
                            : (value) {
                                if (mounted) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                }
                              },
                      ),
                      Text(
                        AppConstants.rememberMeLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : _showForgotPasswordDialog,
                    child: Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              AppButtons.primary(
                text: AppConstants.signInLabel,
                onPressed: authProvider.isLoading ? null : _handleLogin,
                loading: authProvider.isLoading,
                showIcon: false,
              ),
            ],
          ),
        );
      },
    );
  }

  //Build signup prompt section
  Widget _buildSignupPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: _navigateToSignupScreen,
          child: Text(
            AppConstants.signUpLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
