import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/enums.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rg_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _unitNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  ResponderType _selectedResponderType = ResponderType.medical;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    _emergencyContactController.dispose();
    _unitNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid campus email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }
    if (!_agreeTerms) {
      setState(() => _errorMessage = 'Please agree to the Campus Safety Protocol.');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final state = context.read<RescueGridState>();
      final newUser = state.registerNewAccount(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
        studentId: _selectedRole == UserRole.student
            ? _studentIdController.text.trim()
            : null,
        department: _departmentController.text.trim(),
        unitNumber: _selectedRole == UserRole.responder
            ? (_unitNumberController.text.trim().isNotEmpty
                ? _unitNumberController.text.trim()
                : 'Unit M-1')
            : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : '+91 98450 12345',
        emergencyContact: _selectedRole == UserRole.student
            ? _emergencyContactController.text.trim()
            : null,
        responderType: _selectedRole == UserRole.responder
            ? _selectedResponderType
            : null,
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created for ${newUser.name}! Welcome to RescueGrid.'),
          backgroundColor: RgColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      switch (newUser.role) {
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
          // Header Top Navy Panel
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.28,
            child: Container(
              color: RgColors.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Colors.white),
                            onPressed: () => context.go('/login'),
                            tooltip: 'Back to Login',
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(PhosphorIconsRegular.shieldCheck, color: Colors.white, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Campus Verified',
                                  style: RgTypography.caption.copyWith(color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'Create an Account',
                        style: RgTypography.displayMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Join your university emergency reporting network',
                        style: RgTypography.bodySmall.copyWith(
                          color: const Color(0xFFB0C4DE),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Scrollable White Form Sheet
          Positioned.fill(
            top: size.height * 0.24,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Role Selection Segmented Bar
                        Text(
                          'SELECT YOUR CAMPUS ROLE',
                          style: RgTypography.caption.copyWith(
                            color: RgColors.textMuted,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: UserRole.values.map((role) {
                            final isSelected = _selectedRole == role;
                            IconData iconData;
                            switch (role) {
                              case UserRole.student:
                                iconData = PhosphorIconsRegular.graduationCap;
                                break;
                              case UserRole.responder:
                                iconData = PhosphorIconsRegular.firstAid;
                                break;
                              case UserRole.admin:
                                iconData = PhosphorIconsRegular.buildings;
                                break;
                            }

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedRole = role),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? RgColors.primary : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? RgColors.primary : RgColors.border,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: RgColors.primary.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        iconData,
                                        size: 20,
                                        color: isSelected ? Colors.white : RgColors.textSecondary,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        role.displayName,
                                        style: RgTypography.caption.copyWith(
                                          color: isSelected ? Colors.white : RgColors.textPrimary,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Error Banner
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

                        // Full Name
                        RgTextField(
                          label: 'Full Name',
                          hint: 'e.g., Rohit Sharma',
                          controller: _nameController,
                          prefixIcon: const Icon(PhosphorIconsRegular.user, size: 20),
                        ),
                        const SizedBox(height: 14),

                        // Campus Email
                        RgTextField(
                          label: 'Campus Email',
                          hint: 'e.g., rohit.sharma@pes.edu',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(PhosphorIconsRegular.envelope, size: 20),
                        ),
                        const SizedBox(height: 14),

                        // Contact Phone
                        RgTextField(
                          label: 'Phone Number',
                          hint: '+91 98450 12345',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(PhosphorIconsRegular.phone, size: 20),
                        ),
                        const SizedBox(height: 14),

                        // Role-specific fields
                        if (_selectedRole == UserRole.student) ...[
                          RgTextField(
                            label: 'Student / Roll ID',
                            hint: 'e.g., PES1UG24CS001',
                            controller: _studentIdController,
                            prefixIcon: const Icon(PhosphorIconsRegular.identificationCard, size: 20),
                          ),
                          const SizedBox(height: 14),
                          RgTextField(
                            label: 'Hostel Block / Department',
                            hint: 'e.g., Cauvery Block · Computer Science',
                            controller: _departmentController,
                            prefixIcon: const Icon(PhosphorIconsRegular.door, size: 20),
                          ),
                          const SizedBox(height: 14),
                          RgTextField(
                            label: 'Emergency Contact (Name & Phone)',
                            hint: 'e.g., Parent · +91 98450 99999',
                            controller: _emergencyContactController,
                            prefixIcon: const Icon(PhosphorIconsRegular.users, size: 20),
                          ),
                          const SizedBox(height: 14),
                        ] else if (_selectedRole == UserRole.responder) ...[
                          Text(
                            'RESPONDER UNIT SPECIALTY',
                            style: RgTypography.caption.copyWith(
                              color: RgColors.textMuted,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: ResponderType.values.map((type) {
                              final isSelected = _selectedResponderType == type;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: ChoiceChip(
                                    label: Text(type.label),
                                    selected: isSelected,
                                    selectedColor: RgColors.primary,
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : RgColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                    showCheckmark: false,
                                    onSelected: (val) {
                                      if (val) setState(() => _selectedResponderType = type);
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          RgTextField(
                            label: 'Unit Call Sign / Assigned Vehicle',
                            hint: 'e.g., Unit M-4 (Rapid Medic)',
                            controller: _unitNumberController,
                            prefixIcon: const Icon(PhosphorIconsRegular.radio, size: 20),
                          ),
                          const SizedBox(height: 14),
                        ] else ...[
                          RgTextField(
                            label: 'Station / Department',
                            hint: 'e.g., Campus Safety Dispatch Central',
                            controller: _departmentController,
                            prefixIcon: const Icon(PhosphorIconsRegular.buildings, size: 20),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Password
                        RgTextField(
                          label: 'Password',
                          hint: 'At least 6 characters',
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
                        const SizedBox(height: 14),

                        // Confirm Password
                        RgTextField(
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: const Icon(PhosphorIconsRegular.lockSimple, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Campus Safety Agreement Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _agreeTerms,
                                activeColor: RgColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'I agree to the Campus Safety & Emergency Protocol and understand emergency calls are geolocated.',
                                style: RgTypography.caption.copyWith(color: RgColors.textSecondary, fontSize: 11.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        PrimaryButton(
                          label: 'Create Account & Sign In',
                          icon: PhosphorIconsRegular.userPlus,
                          isLoading: _isLoading,
                          onPressed: _handleRegister,
                        ),
                        const SizedBox(height: 16),

                        // Link back to Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: RgTypography.bodySmall.copyWith(color: RgColors.textSecondary),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: Text(
                                'Sign In',
                                style: RgTypography.bodySmall.copyWith(
                                  color: RgColors.primaryAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
