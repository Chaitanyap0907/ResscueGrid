import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/enums.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _gpsSharingEnabled = true;
  bool _audioOverrideEnabled = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final user = state.currentUser;
    final isResponder = user.role == UserRole.responder;

    return Scaffold(
      backgroundColor: RgColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account & Safety Settings',
                style: RgTypography.displayMedium,
              ),
              Text(
                'Campus identity credentials and dispatch configuration',
                style: RgTypography.bodySmall,
              ),
              const SizedBox(height: 20),

              // Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                  border: Border.all(color: RgColors.border),
                  boxShadow: RgDimensions.cardShadow,
                ),
                child: Row(
                  children: [
                    UserAvatar(
                      initials: user.initials,
                      size: 64,
                      backgroundColor: RgColors.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.name,
                                style: RgTypography.headingMedium.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: RgTypography.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: RgColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.role.displayName.toUpperCase(),
                              style: RgTypography.badgeLabel.copyWith(
                                color: RgColors.primaryAccent,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Responder Specific Credentials
              if (isResponder && user.skills.isNotEmpty) ...[
                Text(
                  'Verified Response Credentials',
                  style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                    border: Border.all(color: RgColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(PhosphorIconsRegular.certificate, color: RgColors.primaryAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Active Unit: ${user.unitNumber ?? "Unit S-3"}',
                            style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.skills.map((skill) {
                          return Chip(
                            label: Text(skill),
                            backgroundColor: RgColors.surfaceMuted,
                            side: const BorderSide(color: RgColors.border),
                            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Preferences & Toggles
              Text(
                'Safety & Device Preferences',
                style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                  border: Border.all(color: RgColors.border),
                  boxShadow: RgDimensions.cardShadow,
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _notificationsEnabled,
                      title: Text('Emergency Push Alerts', style: RgTypography.subheading.copyWith(fontSize: 14)),
                      subtitle: Text('Receive priority broadcast alerts', style: RgTypography.caption),
                      activeColor: RgColors.primaryAccent,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: _gpsSharingEnabled,
                      title: Text('Continuous Campus GPS', style: RgTypography.subheading.copyWith(fontSize: 14)),
                      subtitle: Text('Provides precise telemetry to responders', style: RgTypography.caption),
                      activeColor: RgColors.primaryAccent,
                      onChanged: (val) => setState(() => _gpsSharingEnabled = val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: _audioOverrideEnabled,
                      title: Text('Critical Siren Audio Override', style: RgTypography.subheading.copyWith(fontSize: 14)),
                      subtitle: Text('Bypasses silent mode for SOS and incoming dispatch', style: RgTypography.caption),
                      activeColor: RgColors.secondary,
                      onChanged: (val) => setState(() => _audioOverrideEnabled = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Demo Control: Simulation engine
              Text(
                'Demo & Evaluator Controls',
                style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                  border: Border.all(color: RgColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(PhosphorIconsRegular.cpu, color: RgColors.primaryAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Live Incident Simulation Engine',
                                style: RgTypography.caption.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                state.isAutoSimulationEnabled
                                    ? 'Engine active (ticks every 4s to simulate movement and dispatch)'
                                    : 'Engine paused (manual mode)',
                                style: RgTypography.caption.copyWith(color: RgColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: state.isAutoSimulationEnabled,
                          activeColor: RgColors.primaryAccent,
                          onChanged: (_) => state.toggleAutoSimulation(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(PhosphorIconsRegular.arrowCounterClockwise, size: 16),
                          label: const Text('Reset Demo State'),
                          onPressed: () {
                            state.resetDemo();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Demo state reset to initial conditions.')),
                            );
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(PhosphorIconsRegular.palette, size: 16),
                          label: const Text('Component Showcase'),
                          onPressed: () => context.push('/showcase'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Log Out Button
              PrimaryButton(
                label: 'Sign Out & Return to Login',
                isSecondary: true,
                icon: PhosphorIconsRegular.signOut,
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
