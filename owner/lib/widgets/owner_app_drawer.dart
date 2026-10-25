import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../screens/settings_screen.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../screens/role_selection_screen.dart';

class OwnerAppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onSelectTab;

  const OwnerAppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? AppColors.darkBackground : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;

        return Drawer(
          backgroundColor: bgColor,
          child: Column(
            children: [
              // Drawer Header with Official Logo & Profile
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.skyBlue, width: 2),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.shield_rounded, color: AppColors.primaryBlue, size: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SecureTrack SL',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Sri Lanka Customs',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFBAE6FD),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ValueListenableBuilder<OwnerProfileModel>(
                      valueListenable: ApiService.currentOwnerNotifier,
                      builder: (context, owner, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              owner.fullName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              owner.companyName,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFBAE6FD),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              owner.email,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.skyBlue.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'Tier 1 Verified Importer • LL-SL-2026',
                        style: GoogleFonts.poppins(
                          color: AppColors.skyBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Drawer Navigation Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  children: [
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.dashboard_rounded,
                      title: settings.tr('dashboard'),
                      isSelected: currentIndex == 0,
                      onTap: () {
                        Navigator.pop(context);
                        onSelectTab(0);
                      },
                      textColor: textColor,
                      isDark: isDark,
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.location_on_rounded,
                      title: settings.tr('tracking'),
                      isSelected: currentIndex == 1,
                      onTap: () {
                        Navigator.pop(context);
                        onSelectTab(1);
                      },
                      textColor: textColor,
                      isDark: isDark,
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.notifications_rounded,
                      title: settings.tr('alerts'),
                      isSelected: currentIndex == 2,
                      onTap: () {
                        Navigator.pop(context);
                        onSelectTab(2);
                      },
                      textColor: textColor,
                      isDark: isDark,
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.all_inbox_rounded,
                      title: settings.tr('containers'),
                      isSelected: currentIndex == 3,
                      onTap: () {
                        Navigator.pop(context);
                        onSelectTab(3);
                      },
                      textColor: textColor,
                      isDark: isDark,
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.person_rounded,
                      title: settings.tr('profile'),
                      isSelected: currentIndex == 4,
                      onTap: () {
                        Navigator.pop(context);
                        onSelectTab(4);
                      },
                      textColor: textColor,
                      isDark: isDark,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: isDark ? AppColors.darkBorder : AppColors.borderLight),
                    ),

                    // Quick Settings
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.settings_rounded,
                      title: settings.tr('settings'),
                      subtitle: '${settings.language.label} • ${isDark ? "Dark" : "Light"}',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                      textColor: textColor,
                      isDark: isDark,
                    ),

                    // Sri Lanka Customs Hotline 1937
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.support_agent_rounded,
                      title: 'Customs Hotline',
                      subtitle: 'Emergency 1937 / +94 11 222 1937',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        _showHotlineDialog(context, isDark, textColor);
                      },
                      textColor: textColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // Drawer Footer (Log Out)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight)),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  tileColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  leading: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
                  title: Text(
                    settings.tr('sign_out'),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFFDC2626)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color textColor,
    required bool isDark,
  }) {
    final activeBg = isDark ? const Color(0xFF0B3A5A) : const Color(0xFFE0EDFB);
    final activeColor = isDark ? AppColors.skyBlue : AppColors.primaryBlue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? activeColor : (isDark ? Colors.white70 : const Color(0xFF64748B)),
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? activeColor : textColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  void _showHotlineDialog(BuildContext context, bool isDark, Color textColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.shield_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 10),
            Text('Sri Lanka Customs', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customs Emergency Operations Center:', style: GoogleFonts.poppins(fontSize: 13, color: textColor)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0EDFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.phone_in_talk, color: AppColors.primaryBlue),
                  SizedBox(width: 10),
                  Text('Shortcode: 1937 (Toll-Free)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Available 24/7 for tamper alerts, route hijacking, and maritime container inspection queries.', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
