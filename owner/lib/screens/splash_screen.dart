import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'role_selection_screen.dart';

/// Splash screen matching the Sri Lanka Customs Navy & Sky Blue theme
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Continuous subtle breathing/pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Initial entrance scale & fade animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeIn,
    );

    _scaleController.forward();

    _timer = Timer(const Duration(milliseconds: 3200), () {
      _navigateToRoleSelection();
    });
  }

  void _navigateToRoleSelection() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyBackground,
      body: GestureDetector(
        onTap: _navigateToRoleSelection,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleController, _pulseController]),
            builder: (context, child) {
              final pulseValue = _pulseController.value;
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Radar Ripple / Glow Ring 1
                          Container(
                            width: 210 + (pulseValue * 30),
                            height: 210 + (pulseValue * 30),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.skyBlue.withValues(alpha: 0.06 * (1 - pulseValue)),
                              border: Border.all(
                                color: AppColors.skyBlue.withValues(alpha: 0.25 * (1 - pulseValue)),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Middle Glowing Ring 2
                          Container(
                            width: 175 + (pulseValue * 15),
                            height: 175 + (pulseValue * 15),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBlue.withValues(alpha: 0.35),
                              border: Border.all(
                                color: AppColors.skyBlue.withValues(alpha: 0.5),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.skyBlue.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          // Center Official Logo Hero
                          Transform.scale(
                            scale: 1.0 + (pulseValue * 0.04),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo_bw.png',
                                  width: 135,
                                  height: 135,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/logo.png',
                                    width: 135,
                                    height: 135,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.shield_rounded,
                                      size: 90,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'SecureTrack SL',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'IoT Container Monitoring Framework',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.skyLight.withValues(alpha: 0.8),
                          letterSpacing: 0.4,
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
