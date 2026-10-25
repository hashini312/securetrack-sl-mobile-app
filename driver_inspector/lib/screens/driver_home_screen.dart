import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../models/driver_models.dart';
import '../services/driver_api_service.dart';

class DriverHomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;
  final VoidCallback? onOpenDrawer;

  const DriverHomeScreen({
    super.key,
    required this.onNavigateTab,
    this.onOpenDrawer,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  void _triggerEmergencyAlert(DriverTripModel trip) {
    final isDark = AppSettingsController.instance.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Emergency Alert',
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
          'Are you sure you want to trigger a priority emergency alert to Sri Lanka Customs control center?',
          style: TextStyle(
            color: isDark ? const Color(0xFFCBD5E1) : AppColors.textDark,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(ctx);
              await DriverApiService.sendEmergencyAlert(trip.containerNo, 'Driver assistance required');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFFEF4444),
                    content: Text('🚨 Emergency alert dispatched to Customs & Monitoring Officers!'),
                  ),
                );
              }
            },
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  void _confirmStartTrip(DriverTripModel trip) {
    final isDark = AppSettingsController.instance.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF16A34A)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Start Trip Transit',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you ready to depart ${trip.startLocation} and begin transit to ${trip.destination}?',
              style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFCBD5E1) : AppColors.textDark),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _dialogRow('Container', trip.containerNo, isDark),
                  const SizedBox(height: 6),
                  _dialogRow('Route', '${trip.startLocation} ➔ ${trip.destination}', isDark),
                  const SizedBox(height: 6),
                  _dialogRow('Smart Seal', 'Locked & Calibrated', isDark),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ Sri Lanka Customs GPS tracking corridor will activate immediately.',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await DriverApiService.startTrip();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF16A34A),
                    content: Text('🚀 Trip started! Active corridor tracking initiated.'),
                  ),
                );
              }
            },
            child: const Text('Start Transit'),
          ),
        ],
      ),
    );
  }

  void _confirmEndTrip(DriverTripModel trip) {
    final isDark = AppSettingsController.instance.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.flag_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Complete Trip & Arrival',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Have you arrived safely at ${trip.destination} destination?',
              style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFCBD5E1) : AppColors.textDark),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _dialogRow('Destination', trip.destination, isDark),
                  const SizedBox(height: 6),
                  _dialogRow('Status', 'Mark as COMPLETED', isDark),
                  const SizedBox(height: 6),
                  _dialogRow('Next Action', 'Await Customs Seal Clearance', isDark),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ℹ️ This logs final transit timestamp for Sri Lanka Customs clearance.',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await DriverApiService.completeTrip();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF1E3A8A),
                    content: Text('🏁 Trip Completed! Destination arrival logged for Customs clearance.'),
                  ),
                );
              }
            },
            child: const Text('Confirm Arrival'),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value, [bool isDark = false]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
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
        final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

        return ValueListenableBuilder<DriverTripModel>(
          valueListenable: DriverApiService.currentTripNotifier,
          builder: (context, trip, _) {
            final isPlanned = trip.status.toUpperCase() == 'PLANNED';
            final isCompleted = trip.status.toUpperCase() == 'COMPLETED';

            return Scaffold(
              backgroundColor: bgColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Driver Welcome Banner (100% matched to Owner and Inspector Header Signature)
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
                                        onPressed: widget.onOpenDrawer,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ValueListenableBuilder<DriverProfileModel>(
                                          valueListenable: DriverApiService.currentDriverNotifier,
                                          builder: (context, driver, _) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${settings.tr('hello')}, ${driver.fullName}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  driver.vehicleNo,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                                        padding: const EdgeInsets.all(6),
                                        constraints: const BoxConstraints(),
                                      tooltip: settings.tr('alerts'),
                                      onPressed: () => widget.onNavigateTab(3),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 22),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // 3 Metric Pills inside banner (Identical to Owner Banner)
                            Row(
                              children: [
                                _buildMetricPill('24', 'Total Trips', Colors.white, Colors.white.withValues(alpha: 0.18)),
                                const SizedBox(width: 10),
                                _buildMetricPill('98%', 'On-Time', Colors.white, Colors.white.withValues(alpha: 0.18)),
                                const SizedBox(width: 10),
                                _buildMetricPill('3.2k', 'km Total', Colors.white, Colors.white.withValues(alpha: 0.18)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Assigned Trip',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            isPlanned ? 'Ready to Depart' : (isCompleted ? 'Destination Arrived' : 'Active Corridor'),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isPlanned
                                  ? const Color(0xFFD97706)
                                  : (isCompleted ? const Color(0xFF16A34A) : (isDark ? AppColors.skyBlue : AppColors.primaryBlue)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Current Trip Card (Identical border radius, padding & badge styling to Owner)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Icon + ID + Status Pill
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F2B48) : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.all_inbox_rounded, color: AppColors.primaryBlue, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trip.containerNo,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${trip.type} • ${trip.weight}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStatusPill(trip.status),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 12),

                            // Route Corridor Line with bullet and arrow
                            Row(
                              children: [
                                const Icon(Icons.radio_button_checked, size: 16, color: AppColors.primaryBlue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${trip.startLocation} ➔ ${trip.destination}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Live Map Tap Box
                            InkWell(
                              onTap: () => widget.onNavigateTab(1), // Open Navigation map
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 85,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.location_on, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tap to View Live Route & GPS Corridor',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Info Footer (ETA, Speed/Distance, Seal)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Flexible(child: _buildInfoBadge(Icons.access_time_rounded, 'ETA', trip.eta, textColor)),
                                  const SizedBox(width: 8),
                                  Flexible(child: _buildInfoBadge(Icons.speed_rounded, 'Dist', trip.distanceLeft, textColor)),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    flex: 2,
                                    child: _buildInfoBadge(
                                      Icons.lock_rounded,
                                      'Seal',
                                      trip.sealStatus.contains('(')
                                          ? trip.sealStatus
                                              .replaceAll('Locked (', 'Locked ? ')
                                              .replaceAll(' / IOT-DEV-001)', '')
                                              .replaceAll(')', '')
                                          : trip.sealStatus,
                                      const Color(0xFF16A34A),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Dynamic Trip Action Button (Start Trip / End Trip / Completed)
                            _buildTripActionButton(trip, isDark),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Emergency Alert Button
                      InkWell(
                        onTap: () => _triggerEmergencyAlert(trip),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF4C0519) : const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.notification_important_rounded, color: Color(0xFFE11D48), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Dispatch Emergency Customs Alert',
                                style: TextStyle(
                                  color: Color(0xFFE11D48),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg;
    Color fg;
    String label = status;

    if (status.toUpperCase() == 'PLANNED') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
      label = 'Ready to Depart';
    } else if (status.toUpperCase() == 'COMPLETED') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
      label = 'Completed';
    } else {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF16A34A);
      label = 'In Transit';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTripActionButton(DriverTripModel trip, bool isDark) {
    final status = trip.status.toUpperCase();

    if (status == 'PLANNED') {
      // START TRIP BUTTON
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => _confirmStartTrip(trip),
          icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
          label: const Text(
            'Start Trip (Begin Transit)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    } else if (status == 'COMPLETED') {
      // COMPLETED BANNER + RESET OPTION
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F2B1D) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Trip Completed • Awaiting Customs Clearance',
                style: TextStyle(
                  color: Color(0xFF166534),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                DriverApiService.resetTrip();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trip reset to PLANNED for demonstration.')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Text('Reset', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
              ),
            ),
          ],
        ),
      );
    } else {
      // END TRIP (COMPLETE) BUTTON
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => _confirmEndTrip(trip),
          icon: const Icon(Icons.flag_rounded, size: 22),
          label: const Text(
            'End Trip (Arrived at Destination)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }
  }

  Widget _buildMetricPill(String count, String label, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label, String value, Color valueColor, {int maxLines = 1}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 14, color: AppColors.textMuted),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
