import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import 'role_selection_screen.dart';

class InspectorProfileScreen extends StatelessWidget {
  final String officerName;
  final String badgeNo;
  final String email;
  final String dutyStation;
  final String intercom;
  final VoidCallback? onBackToHome;
  final Function(String newStation, String newIntercom) onStationChanged;

  const InspectorProfileScreen({
    super.key,
    required this.officerName,
    this.badgeNo = 'INSP-13',
    this.email = 'hasitha@gmail.com',
    required this.dutyStation,
    required this.intercom,
    this.onBackToHome,
    required this.onStationChanged,
  });

  void _showEditStationDialog(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color cardColor,
    Color borderColor,
  ) {
    final formKey = GlobalKey<FormState>();
    String selectedStation = dutyStation;

    final stations = [
      'Katunayake BOI',
      'Biyagama FTZ',
      'Orugodawatta Customs Yard',
      'Colombo Port Gate 01',
      'Colombo Port Gate 04',
    ];

    if (!stations.contains(selectedStation)) {
      selectedStation = stations.first;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor),
          ),
          title: Row(
            children: [
              const Icon(Icons.badge_rounded, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Change Duty Terminal',
                style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Designated Inspection Terminal', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStation,
                      dropdownColor: cardColor,
                      isExpanded: true,
                      items: stations
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: textColor, fontSize: 13))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedStation = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newIntercom = selectedStation.contains('Biyagama')
                      ? '+94 11 556 7788 (Ext 1205)'
                      : (selectedStation.contains('Orugodawatta')
                          ? '+94 11 222 3344 (Ext 4012)'
                          : '+94 11 243 2191 (Ext 8941)');
                  onStationChanged(selectedStation, newIntercom);
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Terminal'),
            ),
          ],
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
        final bgColor = isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC);
        final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              tooltip: 'Back',
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else if (onBackToHome != null) {
                  onBackToHome!();
                }
              },
            ),
            title: Text(
              'Inspector Profile',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
            ),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Top Officer Identification Card (100% matched to Owner Company Header Card)
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0B3A5A) : AppColors.skyLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.4)),
                        ),
                        child: Icon(
                          Icons.verified_user_rounded,
                          color: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              officerName,
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Badge ID: $badgeNo • Customs Enforcement',
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Tier 1 Verified Inspector (AEO)',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF166534),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Inspector Profile Details Card (100% matched to Company Profile Details Card)
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Inspector Profile',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          InkWell(
                            onTap: () => _showEditStationDialog(context, isDark, textColor, cardColor, borderColor),
                            child: Row(
                              children: [
                                const Icon(Icons.edit_location_alt_rounded, size: 16, color: AppColors.primaryBlue),
                                const SizedBox(width: 4),
                                Text(
                                  'Change Station',
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildProfileRow(Icons.email_outlined, 'Official Email', email, textColor),
                      Divider(height: 24, color: borderColor),
                      _buildProfileRow(Icons.phone_outlined, 'Direct Hotline', intercom, textColor),
                      Divider(height: 24, color: borderColor),
                      _buildProfileRow(Icons.location_on_outlined, 'Registered Office', dutyStation, textColor),
                      Divider(height: 24, color: borderColor),
                      _buildProfileRow(Icons.badge_outlined, 'Customs TIN Code', 'TIN-104928190 (SLC-$badgeNo)', textColor),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Account Statistics Card (100% matched to Owner Account Statistics 4 boxes)
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Statistics',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatBox('12', 'Active Queue', const Color(0xFF16A34A), isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7)),
                          const SizedBox(width: 12),
                          _buildStatBox('48', 'Cleared Today', const Color(0xFF0284C7), isDark ? const Color(0xFF0369A1) : const Color(0xFFE0F2FE)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatBox('60', 'Total Inspected', isDark ? Colors.white70 : const Color(0xFF475569), isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                          const SizedBox(width: 12),
                          _buildStatBox('2', 'Alerts Flagged', const Color(0xFFDC2626), isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Log Out Button (100% matched to Owner / Driver Red Outlined Button)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
                    label: Text(
                      settings.tr('sign_out'),
                      style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileRow(IconData icon, String title, String value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String count, String label, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: textColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
