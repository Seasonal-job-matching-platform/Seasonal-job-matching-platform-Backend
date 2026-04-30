import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/constants/constants.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/providers/auth_provider.dart';

import 'package:job_seeker/screens/layout_screen.dart';
import 'package:job_seeker/theme/app_theme.dart';
import 'package:job_seeker/widgets/common/animated_scale_button.dart';
import 'package:job_seeker/widgets/common/staggered_list_item.dart';
import 'package:job_seeker/widgets/common/gradient_button.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  String _completePhoneNumber = '';
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasNavigated = false;

  late AnimationController _headerAnimController;
  late Animation<double> _headerScaleAnimation;

  // Password strength tracking
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();

    _headerAnimController = AnimationController(
      duration: AppTheme.animSlow,
      vsync: this,
    );

    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimController,
        curve: AppTheme.curveBounce,
      ),
    );

    _headerAnimController.forward();

    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _nameController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;
    String strengthText = '';
    Color strengthColor = Colors.grey;

    if (password.isEmpty) {
      strength = 0.0;
      strengthText = '';
    } else if (password.length < 6) {
      strength = 0.2;
      strengthText = 'Too Short';
      strengthColor = Colors.red;
    } else {
      // Calculate strength based on criteria
      int criteriaCount = 0;
      if (password.length >= 8) criteriaCount++;
      if (password.length >= 12) criteriaCount++;
      if (RegExp(r'[A-Z]').hasMatch(password)) criteriaCount++;
      if (RegExp(r'[a-z]').hasMatch(password)) criteriaCount++;
      if (RegExp(r'[0-9]').hasMatch(password)) criteriaCount++;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) criteriaCount++;

      if (criteriaCount <= 2) {
        strength = 0.4;
        strengthText = 'Weak';
        strengthColor = Colors.orange;
      } else if (criteriaCount <= 4) {
        strength = 0.7;
        strengthText = 'Good';
        strengthColor = Colors.lightGreen;
      } else {
        strength = 1.0;
        strengthText = 'Strong';
        strengthColor = Colors.green;
      }
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.lightImpact();

    try {
      await ref
          .read(authProvider.notifier)
          .signup(
            name: _nameController.text.trim(),
            country: _countryController.text.trim(),
            number: _completePhoneNumber,
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LayoutScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: AppTheme.curveEmphasized,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
            transitionDuration: AppTheme.animNormal,
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            margin: const EdgeInsets.all(AppTheme.spaceMd),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated &&
          mounted &&
          !_hasNavigated) {
        _hasNavigated = true;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LayoutScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: AppTheme.animNormal,
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Gradient Hero Header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.85),
                    colorScheme.secondary.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceLg,
                    AppTheme.spaceMd,
                    AppTheme.spaceLg,
                    AppTheme.spaceXl,
                  ),
                  child: Column(
                    children: [
                      // Back Button Row
                      Row(
                        children: [
                          AnimatedScaleButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spaceSm),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spaceLg),
                      // Animated Icon
                      ScaleTransition(
                        scale: _headerScaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.spaceLg),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person_add_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      // Title
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: AppTheme.animNormal,
                        curve: AppTheme.curveDefault,
                        builder: (context, value, child) {
                          return Opacity(opacity: value, child: child);
                        },
                        child: Text(
                          l10n.createAccount,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceXs),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: AppTheme.animNormal,
                        curve: AppTheme.curveDefault,
                        builder: (context, value, child) {
                          return Opacity(opacity: value, child: child);
                        },
                        child: Text(
                          l10n.fillInDetails,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Personal Information Section
                    StaggeredListItem(
                      index: 0,
                      child: _SectionHeader(
                        icon: Icons.person_outline,
                        title: l10n.personalInformation,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),

                    // Name field
                    StaggeredListItem(
                      index: 1,
                      child: TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          hintText: l10n.enterFullName,
                          prefixIcon: const Icon(Icons.person_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.pleaseEnterName;
                          }
                          if (!RegExp(
                            r'^[a-zA-Z\s]+$',
                          ).hasMatch(value.trim())) {
                            return l10n.nameOnlyLetters;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),

                    // Country field
                    StaggeredListItem(
                      index: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _countryController.text.isEmpty
                            ? null
                            : _countryController.text,
                        onChanged: isLoading
                            ? null
                            : (String? newValue) {
                                if (newValue != null) {
                                  _countryController.text = newValue;
                                }
                              },
                        decoration: InputDecoration(
                          labelText: l10n.country,
                          hintText: l10n.selectCountry,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        items: countryList
                            .map(
                              (country) => DropdownMenuItem(
                                value: country,
                                child: Text(country),
                              ),
                            )
                            .toList(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select your country';
                          }
                          return null;
                        },
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),

                    // Phone Number field
                    StaggeredListItem(
                      index: 3,

                      child: IntlPhoneField(
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          border: OutlineInputBorder(borderSide: BorderSide()),
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        initialCountryCode: 'EG',
                        onChanged: (phone) {
                          _completePhoneNumber = phone.completeNumber;
                        },
                        onCountryChanged: (country) {
                          // Optional: Update country controller if you want to sync them
                        },
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.number.trim().isEmpty) {
                            return l10n.pleaseEnterPhone;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceXl),

                    // Account Information Section
                    StaggeredListItem(
                      index: 4,
                      child: _SectionHeader(
                        icon: Icons.security_outlined,
                        title: l10n.accountSecurity,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),

                    // Email field
                    StaggeredListItem(
                      index: 5,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          hintText: l10n.enterYourEmail,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.pleaseEnterEmail;
                          }
                          if (!RegExp(
                            r'^[\w\.-]+@[\w\.-]+\.\w{2,}$',
                          ).hasMatch(value)) {
                            return l10n.pleaseEnterValidEmail;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),

                    // Password field with strength indicator
                    StaggeredListItem(
                      index: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              hintText: l10n.createStrongPassword,
                              helperText: l10n.passwordAtLeast8,
                              helperMaxLines: 2,
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterPassword;
                              }
                              if (value.length < 6) {
                                return l10n.passwordAtLeast6;
                              }
                              return null;
                            },
                          ),
                          // Password Strength Indicator
                          if (_passwordController.text.isNotEmpty) ...[
                            const SizedBox(height: AppTheme.spaceSm),
                            _PasswordStrengthIndicator(
                              strength: _passwordStrength,
                              strengthText: _passwordStrengthText,
                              strengthColor: _passwordStrengthColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),

                    // Confirm Password field
                    StaggeredListItem(
                      index: 7,
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => _handleSignup(),
                        decoration: InputDecoration(
                          labelText: l10n.confirmPassword,
                          hintText: l10n.confirmYourPassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseConfirmPassword;
                          }
                          if (value != _passwordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceXl),

                    // Signup button
                    StaggeredListItem(
                      index: 8,
                      child: GradientButton(
                        label: 'Create Account',
                        onPressed: isLoading ? null : _handleSignup,
                        isLoading: isLoading,
                        icon: Icons.person_add,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceLg),

                    // Login link
                    StaggeredListItem(
                      index: 9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.alreadyHaveAccount,
                            style: theme.textTheme.bodyMedium,
                          ),
                          AnimatedScaleButton(
                            onPressed: () {
                              if (isLoading) return;
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              l10n.login,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spaceSm),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: AppTheme.spaceSm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Password Strength Indicator Widget
class _PasswordStrengthIndicator extends StatelessWidget {
  final double strength;
  final String strengthText;
  final Color strengthColor;

  const _PasswordStrengthIndicator({
    required this.strength,
    required this.strengthText,
    required this.strengthColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: strength),
          duration: AppTheme.animFast,
          curve: AppTheme.curveDefault,
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 6,
              ),
            );
          },
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Row(
          children: [
            Icon(
              strength >= 0.7
                  ? Icons.check_circle
                  : strength >= 0.4
                  ? Icons.info
                  : Icons.warning,
              size: 14,
              color: strengthColor,
            ),
            const SizedBox(width: AppTheme.spaceXs),
            Text(
              strengthText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
