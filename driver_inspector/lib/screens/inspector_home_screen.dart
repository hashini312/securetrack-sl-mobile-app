import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';

class InspectorHomeScreen extends StatelessWidget {
  final String dutyStation;
  final String officerName;
  final String queueFilter;
  final List<Map<String, dynamic>> queue;
  final Function(String filter) onFilterChanged;
  final Function(String containerId, String sealId) onSelectForInspection;
  final VoidCallback onOpenDrawer;
  final VoidCallback onNavigateToAlerts;

  const InspectorHomeScreen({
    super.key,
    required this.dutyStation,
    required this.officerName,
    required this.queueFilter,
    required this.queue,
    required this.onFilterChanged,
    required this.onSelectForInspection,
    required this.onOpenDrawer,
    required this.onNavigateToAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;
    final isDark = settings.isDarkMode;
    final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

    final pendingCount = queue.where((c) => !c['status'].toString().contains('Cleared')).length;
    final clearedCount = queue.where((c) => c['status'].toString().contains('Cleared')).length;
    final priorityCount = queue.where((c) => c['risk'].toString().contains('Standard') || c['risk'].toString().contains('High')).length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inspector Header Card
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                        tooltip: 'Menu',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onOpenDrawer,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                            tooltip: 'Alerts',
                            onPressed: onNavigateToAlerts,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4ADE80),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dutyStation,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Customs Officer Dashboard',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    officerName,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Metric Row
                  Row(
                    children: [
                      _buildMetricPill('$pendingCount', 'Pending Inspection', Colors.white, Colors.white.withValues(alpha: 0.18)),
                      const SizedBox(width: 10),
                      _buildMetricPill('$clearedCount', 'Cleared Today', const Color(0xFF4ADE80), Colors.black.withValues(alpha: 0.25)),
                      const SizedBox(width: 10),
                      _buildMetricPill('$priorityCount', 'Priority Review', const Color(0xFFFBBF24), Colors.black.withValues(alpha: 0.25)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Queue Title & Filter Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Inspection Queue',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    Text(
                      '${queue.length} Total',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQueueFilterChip('All', queueFilter == 'All', () => onFilterChanged('All'), isDark),
                      const SizedBox(width: 8),
                      _buildQueueFilterChip('Pending', queueFilter == 'Pending', () => onFilterChanged('Pending'), isDark),
                      const SizedBox(width: 8),
                      _buildQueueFilterChip('Seal Review', queueFilter == 'Seal Review', () => onFilterChanged('Seal Review'), isDark),
                      const SizedBox(width: 8),
                      _buildQueueFilterChip('Cleared', queueFilter == 'Cleared', () => onFilterChanged('Cleared'), isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Container Cards
                ...queue.map((c) => _buildQueueContainerCard(c, cardColor, textColor, borderColor, isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String count, String label, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(count, style: GoogleFonts.poppins(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.85), fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueFilterChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.skyBlue : AppColors.primaryBlue)
              : (isDark ? AppColors.darkCardBg : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.skyBlue : AppColors.primaryBlue)
                : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildQueueContainerCard(
    Map<String, dynamic> c,
    Color cardColor,
    Color textColor,
    Color borderColor,
    bool isDark,
  ) {
    final isCleared = c['status'].toString().contains('Cleared');
    final tagMatch = RegExp(r'IOT-DEV-\d+').firstMatch(c['seal'] ?? '');
    final sealId = tagMatch != null ? tagMatch.group(0)! : 'IOT-DEV-001';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0B3A5A) : const Color(0xFFE0EDFB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.inventory_2_rounded, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['id'], style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                        Text(c['haulier'], style: GoogleFonts.poppins(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (c['riskColor'] as Color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    c['risk'],
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: c['riskColor']),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            _buildInfoRow(Icons.alt_route_rounded, 'Corridor', c['route'], textColor, isDark),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.qr_code_rounded, 'Smart Seal', c['seal'], isDark ? AppColors.skyBlue : AppColors.primaryBlue, isDark),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.local_shipping_outlined, 'Truck & Driver', '${c['vehicle']} • ${c['driver']}', textColor, isDark),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isCleared
                        ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCleared ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                        size: 14,
                        color: isCleared ? const Color(0xFF16A34A) : (isDark ? AppColors.skyBlue : AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        c['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCleared ? const Color(0xFF16A34A) : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => onSelectForInspection(c['id'], sealId),
                  icon: const Icon(Icons.verified_user_rounded, size: 14),
                  label: Text('Inspect', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color valueColor, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted),
        const SizedBox(width: 6),
        Text('$label: ', style: GoogleFonts.poppins(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted)),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: valueColor),
          ),
        ),
      ],
    );
  }
}
