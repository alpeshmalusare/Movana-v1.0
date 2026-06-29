import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/movana_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _markOpacity;
  late final Animation<double> _markScale;
  late final Animation<double> _markGlow;
  late final Animation<double> _sweep;
  late final Animation<double> _fadeToBlack;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2450));
    _markOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 36),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 44),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 20),
    ]).animate(_controller);
    _markScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: .76, end: 1).chain(CurveTween(curve: Curves.easeOutBack)), weight: 42),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.08).chain(CurveTween(curve: Curves.easeInOutCubic)), weight: 24),
      TweenSequenceItem(tween: Tween<double>(begin: 1.08, end: 2.85).chain(CurveTween(curve: Curves.easeInOutCubic)), weight: 34),
    ]).animate(_controller);
    _markGlow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 46),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: .55).chain(CurveTween(curve: Curves.easeInOutCubic)), weight: 28),
      TweenSequenceItem(tween: Tween<double>(begin: .55, end: 0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 26),
    ]).animate(_controller);
    _sweep = Tween<double>(begin: -1.7, end: 1.7).animate(CurvedAnimation(parent: _controller, curve: const Interval(.28, .72, curve: Curves.easeInOutCubic)));
    _fadeToBlack = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(.72, 1, curve: Curves.easeInCubic)));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [Color.lerp(const Color(0xFF161000), Colors.black, _fadeToBlack.value)!, Colors.black],
                  ),
                ),
              ),
              Center(
                child: Opacity(
                  opacity: _markOpacity.value,
                  child: Transform.scale(
                    scale: _markScale.value,
                    child: _CinematicMovanaMark(glow: _markGlow.value, sweep: _sweep.value),
                  ),
                ),
              ),
              IgnorePointer(child: ColoredBox(color: Colors.black.withOpacity(_fadeToBlack.value))),
            ],
          );
        },
      ),
    );
  }
}

class _CinematicMovanaMark extends StatelessWidget {
  const _CinematicMovanaMark({required this.glow, required this.sweep});

  final double glow;
  final double sweep;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('splash-cinematic-m-logo'),
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: MovanaColors.accent.withOpacity(.42 * glow), blurRadius: 58, spreadRadius: 18),
                BoxShadow(color: MovanaColors.accent.withOpacity(.30 * glow), blurRadius: 18, spreadRadius: 1),
              ],
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF1A6), MovanaColors.accent, Color(0xFFC88905)],
            ).createShader(bounds),
            child: const Text('M', style: TextStyle(fontSize: 122, fontWeight: FontWeight.w900, height: .9, color: Colors.white, letterSpacing: 0)),
          ),
          ClipRect(
            child: FractionalTranslation(
              translation: Offset(sweep, 0),
              child: Transform.rotate(
                angle: -.35,
                child: Container(
                  width: 34,
                  height: 190,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(.82), Colors.white.withOpacity(0)],
                    ),
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(.26), blurRadius: 20)],
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