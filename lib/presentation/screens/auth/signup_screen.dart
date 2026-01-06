import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notes_app/core/utils/app_snackbar.dart';
import 'package:notes_app/presentation/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _acceptTerms = false;

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ModernHomeScreen(),
          ),
        );
      } else if (_authProvider.authState == AuthState.error) {
        context.showError(
            _authProvider.errorMessage ?? AppConstants.authErrorMessage);
      }
    };

    // Add listener to auth provider
    _authProvider.addListener(_authListener!);
  }

  //Handle signup form submission with comprehensive validation
  Future<void> _handleSignup() async {
    if (!mounted) return;

    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check terms acceptance
    if (!_acceptTerms) {
      context.showError('Please accept the terms and conditions');
      return;
    }

    // Hide keyboard before processing
    FocusScope.of(context).unfocus();

    try {
      await _authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        context.showError('Sign-up failed: $e');
      }
    }
  }

  //Show terms and conditions dialog
  void _showTermsDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppConstants.termsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Text(
            'By using this app, you agree to our terms and conditions. '
            'This includes:\n\n'
            '1. You will use the app responsibly\n'
            '2. You will not share inappropriate content\n'
            '3. You understand that your data is stored securely\n'
            '4. You can delete your account at any time\n\n'
            'For full terms, please visit our website.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppConstants.closeLabel),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Remove auth listener with proper error handling
    if (_authListener != null) {
      try {
        _authProvider.removeListener(_authListener!);
      } catch (e) {
        debugPrint('SignupScreen: Error removing auth listener: $e');
      }
    }

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppConstants.signUpLabel),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
          _buildSignupForm(),
          SizedBox(height: 16.h),
          _buildLoginPrompt(),
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
              _buildSignupForm(),
              SizedBox(height: 20.h),
              _buildLoginPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  //Build screen header with app branding
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.person_add,
          size: ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 60.w,
            tablet: 70.w,
          ),
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 16.h),
        Text(
          'Create Account',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign up to get started with ${AppConstants.appName}.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  //Build comprehensive signup form with validation
  Widget _buildSignupForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Name',
                prefixIcon: CupertinoIcons.person,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    Validators.validateRequired(value, 'Name'),
                enabled: !authProvider.isLoading,
              ),
              SizedBox(height: 12.h),
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
                  icon: Icon(_isPasswordVisible
                      ? CupertinoIcons.eye_slash
                      : CupertinoIcons.eye),
                  onPressed: () => setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  }),
                ),
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done,
                validator: Validators.validatePassword,
                enabled: !authProvider.isLoading,
                onFieldSubmitted: (_) => _handleSignup(),
              ),
              SizedBox(height: 12.h),

              // Terms and conditions checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: authProvider.isLoading
                        ? null
                        : (value) =>
                            setState(() => _acceptTerms = value ?? false),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: authProvider.isLoading
                          ? null
                          : () => setState(() => _acceptTerms = !_acceptTerms),
                      child: Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              TextSpan(
                                  text: AppConstants.acceptTermsLabel
                                      .split(' ')
                                      .take(3)
                                      .join(' ')),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: _showTermsDialog,
                                  child: Text(
                                    'Terms and Conditions',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              AppButtons.primary(
                text: AppConstants.signUpLabel,
                onPressed: authProvider.isLoading ? null : _handleSignup,
                loading: authProvider.isLoading,
                showIcon: false,
              ),
            ],
          ),
        );
      },
    );
  }

  //Build login prompt section
  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ),
          child: Text(
            AppConstants.signInLabel,
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
