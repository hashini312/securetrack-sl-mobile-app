import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import 'role_selection_screen.dart';
import 'settings_screen.dart';

class InspectorProfileScreen extends StatelessWidget {
  final String officerName;
  final String dutyStation;
  final String intercom;
  final Function(String newStation, String newIntercom) onStationChanged;

  const InspectorProfileScreen({
    super.key,
    required this.officerName,
    required this.dutyStation,
    required this.intercom,
    required this.onStationChanged,
  });

  void _showEditInspectorDialog(
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
      'Orugodawatta RCT',
      'Colombo Port Gate 04',
      'Peliyagoda Logistics Hub',
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
                'Update Duty Station',
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
                Text('Active Duty Terminal Station', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 6),
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
                      items: stations.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: textColor, fontSize: 13)))).toList(),
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
                          ? '+94 11 268 4411 (Ext 302)'
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
              child: const Text('Save Station'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;
    final isDark = settings.isDarkMode;
    final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Officer Identity Banner
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F2B48) : const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryBlue, width: 2.5),
                      ),
                      child: const Icon(Icons.person_rounded, size: 55, color: AppColors.primaryBlue),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  officerName,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 2),
                Text(
                  'Customs Inspection Officer • INSP-13',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      Text('On Active Shift Duty', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Officer Metrics
          Row(
            children: [
              _buildStatBox('18', 'Inspections', const Color(0xFF0284C7), isDark ? const Color(0xFF0C2A44) : const Color(0xFFE0F2FE)),
              const SizedBox(width: 10),
              _buildStatBox('14', 'Cleared', const Color(0xFF16A34A), isDark ? const Color(0xFF052E16) : const Color(0xFFDCFCE7)),
              const SizedBox(width: 10),
              _buildStatBox('2', 'Flagged', const Color(0xFFDC2626), isDark ? const Color(0xFF380D0D) : const Color(0xFFFEE2E2)),
            ],
          ),

          const SizedBox(height: 24),

          // Station Details Card
          Container(
            padding: const EdgeInsets.all(16),
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
                    Text('Duty Station & Terminal', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                    IconButton(
                      icon: const Icon(Icons.edit_location_alt_rounded, color: AppColors.primaryBlue, size: 20),
                      tooltip: 'Change Duty Station',
                      onPressed: () => _showEditInspectorDialog(context, isDark, textColor, cardColor, borderColor),
                    ),
                  ],
                ),
                const Divider(height: 12),
                _buildProfileRow(Icons.business_rounded, 'Terminal Station', dutyStation, textColor),
                const SizedBox(height: 10),
                _buildProfileRow(Icons.support_agent_rounded, 'Station Intercom', intercom, textColor),
                const SizedBox(height: 10),
                _buildProfileRow(Icons.badge_rounded, 'Badge Authority', 'Sri Lanka Customs Revenue Wing', textColor),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // App Settings Tile
          ListTile(
            tileColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: borderColor)),
            leading: const Icon(Icons.settings_outlined, color: AppColors.primaryBlue),
            title: Text(settings.tr('settings'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),

          const SizedBox(height: 20),

          // Sign Out Button -> Navigates to RoleSelectionScreen!
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
                side: const BorderSide(color: Color(0xFFDC2626)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 10),
        Text('$label: ', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, Color valueColor, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
