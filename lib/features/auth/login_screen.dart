import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/enums.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rg_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'aisha.rahman@campus.edu');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      _errorMessage = null;
    });
  }

  void _handleSignIn() {
    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty) {
      setState(() => _errorMessage = 'Please enter your campus email or ID.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final state = context.read<RescueGridState>();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      final success = state.loginWithCredentials(identifier, password);
      setState(() => _isLoading = false);

      if (!success) {
        setState(() {
          _errorMessage =
              'Invalid credentials. Please check your email or password, or select a demo account below.';
        });
        return;
      }

      // Successful login -> route to role home
      switch (state.currentUser.role) {
        case UserRole.student:
          context.go('/student');
          break;
        case UserRole.responder:
          context.go('/responder');
          break;
        case UserRole.admin:
          context.go('/admin');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: RgColors.primary,
      body: Stack(
        children: [
          // Background subtle grid decoration on top navy panel
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.36,
            child: Container(
              color: RgColors.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo: Shield + signal-grid mark
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: RgColors.primaryAccent,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            PhosphorIconsFill.shieldWarning,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'RescueGrid',
                        style: RgTypography.displayMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Campus Emergency Reporting & Dispatch',
                        style: RgTypography.bodySmall.copyWith(
                          color: const Color(0xFFB0C4DE),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // White overlapping sheet
          Positioned.fill(
            top: size.height * 0.30,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sign In Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sign In',
                                style: RgTypography.headingLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Enter your university credentials',
                                style: RgTypography.bodySmall.copyWith(color: RgColors.textSecondary),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => context.go('/register'),
                            icon: const Icon(PhosphorIconsRegular.userPlus, size: 16),
                            label: const Text('New Account'),
                            style: TextButton.styleFrom(
                              foregroundColor: RgColors.primaryAccent,
                              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Error message banner
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF87171)),
                          ),
                          child: Row(
                            children: [
                              const Icon(PhosphorIconsRegular.warningCircle, color: Color(0xFFDC2626), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: RgTypography.caption.copyWith(
                                    color: const Color(0xFF991B1B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email / Campus ID Field
                      RgTextField(
                        label: 'Campus Email or User ID',
                        hint: 'e.g., aisha.rahman@campus.edu or ST-892104',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(PhosphorIconsRegular.envelope, size: 20),
                      ),
                      const SizedBox(height: 14),

                      // Password Field with eye toggle
                      RgTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(PhosphorIconsRegular.lock, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Primary Button: Sign In with Credentials
                      PrimaryButton(
                        label: 'Sign In to RescueGrid',
                        icon: PhosphorIconsRegular.signIn,
                        isLoading: _isLoading,
                        onPressed: _handleSignIn,
                      ),
                      const SizedBox(height: 20),

                      // Create New Account CTA Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: RgColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: RgColors.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(PhosphorIconsRegular.userCirclePlus, color: RgColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'New to RescueGrid?',
                                    style: RgTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Register as Student, Responder or Staff',
                                    style: RgTypography.caption.copyWith(color: RgColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/register'),
                              child: const Text('Create Account'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Demo Account Auto-Fill Bar
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: RgColors.primaryLight,
                          borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
                          border: Border.all(color: RgColors.primaryAccent.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  PhosphorIconsRegular.sparkle,
                                  size: 14,
                                  color: RgColors.primaryAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'QUICK 1-TAP DEMO ACCOUNTS',
                                  style: RgTypography.caption.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: RgColors.primaryAccent,
                                    fontSize: 10,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                ActionChip(
                                  avatar: const Icon(PhosphorIconsRegular.graduationCap, size: 14),
                                  label: const Text('Student: Aisha'),
                                  backgroundColor: Colors.white,
                                  onPressed: () => _fillCredentials('aisha.rahman@campus.edu', 'password123'),
                                ),
                                ActionChip(
                                  avatar: const Icon(PhosphorIconsRegular.firstAid, size: 14),
                                  label: const Text('Responder: Vance'),
                                  backgroundColor: Colors.white,
                                  onPressed: () => _fillCredentials('m.vance@campus-safety.edu', 'password123'),
                                ),
                                ActionChip(
                                  avatar: const Icon(PhosphorIconsRegular.buildings, size: 14),
                                  label: const Text('Admin: Director'),
                                  backgroundColor: Colors.white,
                                  onPressed: () => _fillCredentials('d.hayes@dispatch.campus.edu', 'password123'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Component Showcase Shortcut
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(PhosphorIconsRegular.palette, size: 15),
                          label: const Text('Open Design System & Component Showcase'),
                          onPressed: () => context.push('/showcase'),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Privacy / Terms footer
                      Center(
                        child: Text(
                          'RescueGrid v2.4 · Privacy Policy · Campus Security',
                          style: RgTypography.caption.copyWith(
                            color: RgColors.textMuted,
                            fontSize: 11,
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
    );
  }
}

