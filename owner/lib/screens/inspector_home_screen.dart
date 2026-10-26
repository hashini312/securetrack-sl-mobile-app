import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';

class InspectorHomeScreen extends StatelessWidget {
  final String dutyStation;
  final String officerName;
  final String badgeNo;
  final String queueFilter;
  final List<Map<String, dynamic>> queue;
  final int? activeCount;
  final int? deliveredCount;
  final int? alertsCount;
  final Function(String filter) onFilterChanged;
  final Function(String containerId, String sealId) onSelectForInspection;
  final VoidCallback onOpenDrawer;
  final VoidCallback onNavigateToAlerts;

  const InspectorHomeScreen({
    super.key,
    required this.dutyStation,
    required this.officerName,
    this.badgeNo = 'INSP-13',
    required this.queueFilter,
    required this.queue,
    this.activeCount,
    this.deliveredCount,
    this.alertsCount,
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

    final pendingCount = activeCount ?? queue.where((c) => !c['status'].toString().contains('Cleared')).length;
    final clearedCount = deliveredCount ?? queue.where((c) => c['status'].toString().contains('Cleared')).length;
    final priorityCount = alertsCount ?? queue.where((c) => c['risk'].toString().contains('Standard') || c['risk'].toString().contains('High')).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Blue Officer Banner (100% matched to Owner and Driver Design Signature)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, Color(0xFF1E4E79)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                            tooltip: 'Menu',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onOpenDrawer,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, $officerName',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  dutyStation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                          tooltip: 'Alerts',
                          onPressed: onNavigateToAlerts,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.security_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3 Stats Boxes inside Top Blue Banner
                Row(
                  children: [
                    _buildBannerStatBox('$pendingCount', 'Active', Colors.white.withValues(alpha: 0.12)),
                    const SizedBox(width: 10),
                    _buildBannerStatBox('$clearedCount', 'Delivered', Colors.white.withValues(alpha: 0.12)),
                    const SizedBox(width: 10),
                    _buildBannerStatBox('$priorityCount', 'Alerts', const Color(0xFFEF4444).withValues(alpha: 0.30)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Header Row: Active Shipments + View All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Shipments',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              InkWell(
                onTap: () => onFilterChanged('All'),
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['All', 'Pending', 'Seal Review', 'Cleared'].map((filter) {
                final isSelected = queueFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark),
                    ),
                    backgroundColor: cardColor,
                    selectedColor: AppColors.primaryBlue,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? AppColors.primaryBlue : borderColor),
                    ),
                    onSelected: (_) => onFilterChanged(filter),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Container Cards
          if (queue.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No containers in inspection queue',
                    style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'All scheduled shipments cleared for this station.',
                    style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: queue.length,
              itemBuilder: (context, index) {
                final item = queue[index];
                return _buildContainerCard(
                  context: context,
                  item: item,
                  cardColor: cardColor,
                  textColor: textColor,
                  borderColor: borderColor,
                  isDark: isDark,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBannerStatBox(String count, String label, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCard({
    required BuildContext context,
    required Map<String, dynamic> item,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    required bool isDark,
  }) {
    final id = item['id']?.toString() ?? 'CONT-001';
    final status = item['status']?.toString() ?? 'Pending';
    final seal = item['seal']?.toString() ?? 'IOT-DEV';
    final vehicle = item['vehicle']?.toString() ?? 'Unknown';
    final driver = item['driver']?.toString() ?? 'Unknown Driver';
    final route = item['route']?.toString() ?? 'In Transit Corridor';
    final isCleared = status.contains('Cleared');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Container Icon, Container ID, Status Chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B3A5A) : AppColors.skyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: AppColors.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      id,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '40ft High-Cube • $driver',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCleared ? AppColors.successLight : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCleared ? 'Cleared' : 'In Transit',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Route row with Pin Bullet
          Row(
            children: [
              const Icon(Icons.radio_button_checked_rounded, size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  route,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Sub Info Bar & Inspect Action (100% responsive - never overflows)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF16A34A)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Seal: $seal',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16A34A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vehicle: $vehicle',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => onSelectForInspection(id, seal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 14),
                      const SizedBox(width: 4),
                      Text('Inspect', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
