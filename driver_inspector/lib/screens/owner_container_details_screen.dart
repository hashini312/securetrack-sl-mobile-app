import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_settings.dart';
import 'owner_tracking_screen.dart';

class OwnerContainerDetailsScreen extends StatelessWidget {
  final ContainerItem container;
  const OwnerContainerDetailsScreen({super.key, required this.container});

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
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Container Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white)),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
            actions: [
              IconButton(
                icon: const Icon(Icons.map_outlined, color: Colors.white),
                tooltip: 'Live Tracking Map',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OwnerTrackingScreen(initialContainer: container),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container ID Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        container.containerNo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        container.status,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF16A34A),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Container Information Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Container Specifications', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildInfoCol('Container ID', container.containerNo, textColor)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInfoCol('Type', container.type, textColor)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _buildInfoCol('Weight', container.weight, textColor)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInfoCol('Contents', container.contents, textColor, maxLines: 3)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Assigned Transporter & Fleet Information Card (Read-only official manifest info)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0B3A5A) : const Color(0xFFE0EDFB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_shipping_rounded, color: AppColors.primaryBlue, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned Transporter & Fleet',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '✓ Verified Haulier Partner',
                                    style: TextStyle(
                                      color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTransporterRow(Icons.business_rounded, 'Haulage Contractor', container.transporter, textColor),
                      Divider(height: 20, color: borderColor),
                      _buildTransporterRow(Icons.pin_outlined, 'Assigned Prime Mover', container.vehicleNo, textColor),
                      Divider(height: 20, color: borderColor),
                      _buildTransporterRow(Icons.person_outline_rounded, 'Authorized Driver', container.driverName, textColor),
                      Divider(height: 20, color: borderColor),
                      _buildTransporterRow(Icons.verified_user_outlined, 'Customs Gate Clearance', container.rfidTag, textColor),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Security & Smart Seal Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Security & Smart Seal Status', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 14),

                      // Green Shield Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF065F46) : const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shield_rounded, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'IoT Smart Seal Status',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                                    ),
                                  ),
                                  Text(
                                    container.sealStatus,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.check_circle_rounded, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), size: 20),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildInfoCol('Smart Seal ID', container.sealId, textColor)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInfoCol('Last Telemetry Sync', '2 min ago (Tamper OK)', textColor)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Location History Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transit Corridor Milestones', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 16),

                      _buildTimelineItem(
                        title: 'Colombo Port (Gate 04)',
                        subtitle: 'Origin Dispatch • Sealed with ${container.sealId}',
                        isCurrent: false,
                        isLast: false,
                        textColor: textColor,
                        borderColor: borderColor,
                      ),
                      _buildTimelineItem(
                        title: container.currentRoad,
                        subtitle: 'Live Tracking Location • ${container.status}',
                        isCurrent: true,
                        isLast: false,
                        textColor: textColor,
                        borderColor: borderColor,
                      ),
                      _buildTimelineItem(
                        title: container.destination,
                        subtitle: 'Assigned Corridor Destination • ETA: ${container.eta}',
                        isCurrent: false,
                        isLast: true,
                        textColor: textColor,
                        borderColor: borderColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Button to open Live Map
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OwnerTrackingScreen(initialContainer: container),
                        ),
                      );
                    },
                    icon: const Icon(Icons.navigation_rounded),
                    label: Text('Track Live on GIS Map', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
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

  Widget _buildInfoCol(String label, String value, Color textColor, {int maxLines = 2}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: textColor, height: 1.25),
        ),
      ],
    );
  }

  Widget _buildTransporterRow(IconData icon, String label, String value, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isCurrent,
    required bool isLast,
    required Color textColor,
    required Color borderColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isCurrent ? Icons.radio_button_checked : Icons.circle,
              size: 16,
              color: isCurrent ? AppColors.primaryBlue : const Color(0xFF94A3B8),
            ),
            if (!isLast) Container(width: 2, height: 36, color: borderColor),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
