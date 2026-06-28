import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/movana_theme.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(AppAssets.logo, key: const ValueKey('login-logo'), width: 250),
              const SizedBox(height: 48),
              _LoginButton(
                key: const ValueKey('google-sign-in-button'),
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                background: Colors.white,
                foreground: Colors.black,
                onTap: () async {
                  try {
                    await ref.read(authProvider.notifier).signInWithGoogle();
                    if (context.mounted) context.go('/');
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in failed. Please check Firebase OAuth setup.')));
                    }
                  }
                },
              ),
              const SizedBox(height: 14),
              _LoginButton(
                key: const ValueKey('guest-login-button'),
                label: 'Continue as Guest',
                icon: Icons.person_outline_rounded,
                background: MovanaColors.card,
                foreground: MovanaColors.textPrimary,
                onTap: () async {
                  try {
                    await ref.read(authProvider.notifier).continueAsGuest();
                    if (context.mounted) context.go('/');
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anonymous sign-in failed. Enable it in Firebase Authentication.')));
                    }
                  }
                },
              ),
              const Spacer(),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 18,
                children: const [
                  Text('Privacy Policy', key: ValueKey('privacy-policy-link'), style: TextStyle(color: MovanaColors.textSecondary)),
                  Text('Terms & Conditions', key: ValueKey('terms-link'), style: TextStyle(color: MovanaColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({super.key, required this.label, required this.icon, required this.background, required this.foreground, required this.onTap});

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}