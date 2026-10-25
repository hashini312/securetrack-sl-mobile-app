import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLanguageSelector(BuildContext context, AppSettingsController settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = settings.isDarkMode;
        final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                settings.tr('select_language'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              ...AppLanguage.values.map((lang) {
                final isSelected = settings.language == lang;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF0B3A5A) : const Color(0xFFE0EDFB))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlue : (isDark ? const Color(0xFF334155) : AppColors.borderLight),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: Text(
                      lang.label,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue)
                        : null,
                    onTap: () {
                      settings.setLanguage(lang);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${settings.tr('save_changes')}: ${lang.label}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showHotlineDialog(BuildContext context, AppSettingsController settings) {
    final isDark = settings.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Customs Emergency',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Connecting to Sri Lanka Customs 24/7 National Emergency Hotline:\n\nDial: 1937\n\nControl Room & IT Anti-Theft Monitoring Desk.',
          style: GoogleFonts.poppins(fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulated Call: Connected to Customs 1937 hotline.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('Call Now', style: TextStyle(color: Colors.white)),
          ),
        ],
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
        final bgColor = isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC);
        final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final mutedTextColor = isDark ? const Color(0xFF94A3B8) : AppColors.textMuted;
        final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              settings.tr('settings'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: APPEARANCE & LOCALIZATION ---
                  _buildSectionHeader(settings.tr('appearance'), Icons.palette_outlined, textColor),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        // Theme Toggle
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.15) : const Color(0xFFE0EDFB),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            settings.tr('theme_mode'),
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                          ),
                          subtitle: Text(
                            isDark ? settings.tr('dark_mode') : settings.tr('light_mode'),
                            style: GoogleFonts.poppins(fontSize: 12, color: mutedTextColor),
                          ),
                          trailing: Switch.adaptive(
                            value: isDark,
                            activeTrackColor: AppColors.skyBlue,
                            onChanged: (_) => settings.toggleTheme(),
                          ),
                        ),
                        Divider(height: 1, color: borderColor),
                        // Language Selector
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.15) : const Color(0xFFE0EDFB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.translate_rounded,
                              color: AppColors.primaryBlue,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            settings.tr('language'),
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                          ),
                          subtitle: Text(
                            settings.language.label,
                            style: GoogleFonts.poppins(fontSize: 12, color: mutedTextColor),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                          onTap: () => _showLanguageSelector(context, settings),
                        ),
                        
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION 2: NOTIFICATIONS & ALARMS ---
                  _buildSectionHeader(settings.tr('notifications_alarms'), Icons.notifications_none_rounded, textColor),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          secondary: const Icon(Icons.warning_amber_rounded, color: AppColors.alertRed),
                          title: Text(settings.tr('seal_tamper_siren'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                          subtitle: Text(settings.tr('seal_tamper_siren_sub'), style: GoogleFonts.poppins(fontSize: 11, color: mutedTextColor)),
                          value: settings.sealTamperSiren,
                          activeTrackColor: AppColors.primaryBlue,
                          onChanged: settings.setSealTamperSiren,
                        ),
                        Divider(height: 1, color: borderColor),
                        SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          secondary: const Icon(Icons.alt_route_rounded, color: AppColors.warningOrange),
                          title: Text(settings.tr('route_deviation_alert'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                          subtitle: Text(settings.tr('route_deviation_alert_sub'), style: GoogleFonts.poppins(fontSize: 11, color: mutedTextColor)),
                          value: settings.geofenceAlerts,
                          activeTrackColor: AppColors.primaryBlue,
                          onChanged: settings.setGeofenceAlerts,
                        ),
                        Divider(height: 1, color: borderColor),
                        SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          secondary: const Icon(Icons.battery_alert_rounded, color: AppColors.primaryBlue),
                          title: Text(settings.tr('low_battery_alert'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                          subtitle: Text(settings.tr('low_battery_alert_sub'), style: GoogleFonts.poppins(fontSize: 11, color: mutedTextColor)),
                          value: settings.batteryAlerts,
                          activeTrackColor: AppColors.primaryBlue,
                          onChanged: settings.setBatteryAlerts,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION 3: SRI LANKA CUSTOMS SUPPORT ---
                  _buildSectionHeader(settings.tr('customs_support'), Icons.support_agent_rounded, textColor),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.alertRedLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.alertRed, size: 20),
                      ),
                      title: Text(settings.tr('emergency_hotline'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                      subtitle: Text(settings.tr('emergency_hotline_sub'), style: GoogleFonts.poppins(fontSize: 11, color: mutedTextColor)),
                      trailing: ElevatedButton(
                        onPressed: () => _showHotlineDialog(context, settings),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alertRed,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(settings.tr('call_now'), style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        const Icon(Icons.tune_rounded, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
