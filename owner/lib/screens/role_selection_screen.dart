import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _showPartnerModuleNotice(
    BuildContext context,
    String roleTitle,
    String moduleName,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color borderColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: isDark ? Border(top: BorderSide(color: borderColor)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B3A5A) : AppColors.skyLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.skyBlue, width: 1.5),
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: AppColors.primaryBlue,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '$roleTitle Module',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This module is deployed under the Partner Component ($moduleName). It will be directly accessible through this portal upon final system merge.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Understood', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    bool isPartnerModule = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Uniform Elegant Icon Container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3A8A) : AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? const Color(0xFF93C5FD) : AppColors.skyBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (isPartnerModule) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'Partner',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final sheetBg = isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC);
        final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B132B) : AppColors.navyBackground,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 28),
                // Top Logo and System Header
                Center(
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/logo_bw.png',
                          width: 110,
                          height: 110,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/logo.png',
                            width: 110,
                            height: 110,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.shield_rounded,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'SecureTrack SL',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select your authorized role to continue',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.skyLight.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Bottom Sheet containing all 3 Uniform Cards
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                  decoration: BoxDecoration(
                    color: sheetBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
                        blurRadius: 18,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Role 1: Container Owner (Fully Functional here)
                      _buildRoleCard(
                        context: context,
                        icon: Icons.business_center_rounded,
                        title: 'Container Owner',
                        subtitle: 'Real-time telemetry, tamper alerts & live GPS tracking',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        borderColor: borderColor,
                        isPartnerModule: false,
                      ),

                      // Role 2: Customs Inspector (Allocated to Partner)
                      _buildRoleCard(
                        context: context,
                        icon: Icons.verified_user_rounded,
                        title: 'Customs Inspector',
                        subtitle: 'Clearance verification, smart seal lock & inspection queue',
                        onTap: () => _showPartnerModuleNotice(
                          context,
                          'Customs Inspector',
                          'Inspector / Driver App',
                          isDark,
                          cardColor,
                          textColor,
                          borderColor,
                        ),
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        borderColor: borderColor,
                        isPartnerModule: true,
                      ),

                      // Role 3: Truck Driver (Allocated to Partner)
                      _buildRoleCard(
                        context: context,
                        icon: Icons.local_shipping_rounded,
                        title: 'Truck Driver',
                        subtitle: 'Assigned routes, turn-by-turn navigation & telemetry',
                        onTap: () => _showPartnerModuleNotice(
                          context,
                          'Truck Driver',
                          'Driver App',
                          isDark,
                          cardColor,
                          textColor,
                          borderColor,
                        ),
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        borderColor: borderColor,
                        isPartnerModule: true,
                      ),

                      const SizedBox(height: 8),
                      Text(
                        'Sri Lanka Customs IT Division • Unified Gateway',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
