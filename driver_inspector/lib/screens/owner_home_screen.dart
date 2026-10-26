import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import 'owner_container_details_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;
  final VoidCallback? onOpenDrawer;

  const OwnerHomeScreen({
    super.key,
    required this.onNavigateTab,
    this.onOpenDrawer,
  });

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  List<ContainerItem> _containers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    ApiService.currentOwnerNotifier.addListener(_onOwnerChanged);
    _loadContainers();
  }

  @override
  void dispose() {
    ApiService.currentOwnerNotifier.removeListener(_onOwnerChanged);
    super.dispose();
  }

  void _onOwnerChanged() {
    _loadContainers();
  }

  void _loadContainers() async {
    final list = await ApiService.getOwnerContainers();
    if (mounted) {
      setState(() {
        _containers = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC);
        final textColor = isDark ? Colors.white : AppColors.textDark;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Blue Banner (SRS Page 12 Mockup)
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
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: ValueListenableBuilder<OwnerProfileModel>(
                                            valueListenable: ApiService.currentOwnerNotifier,
                                            builder: (context, owner, _) {
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${settings.tr('hello')}, ${owner.fullName}',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    owner.companyName,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17,
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
                                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                                        tooltip: settings.tr('alerts'),
                                        onPressed: () => widget.onNavigateTab(2),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(Icons.all_inbox_rounded, color: Colors.white, size: 22),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // 3 Metric Boxes (Dynamic to Logged-in Owner) - SRS Page 12
                              Row(
                                children: [
                                  _buildMetricPill('${_containers.where((c) => c.status != 'Delivered').length}', settings.tr('active_containers'), Colors.white, Colors.white.withValues(alpha: 0.18)),
                                  const SizedBox(width: 10),
                                  _buildMetricPill('${_containers.where((c) => c.status == 'Delivered').length}', settings.tr('delivered_containers'), Colors.white, Colors.white.withValues(alpha: 0.18)),
                                  const SizedBox(width: 10),
                                  _buildMetricPill('${ApiService.getOwnerAlerts().length}', settings.tr('alerts'), const Color(0xFFFCA5A5), const Color(0xFFEF4444).withValues(alpha: 0.3)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              settings.tr('recent_containers'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () => widget.onNavigateTab(3), // Navigate to Containers tab
                              child: Text(
                                settings.tr('view_all'),
                                style: GoogleFonts.poppins(
                                  color: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Container Cards List (SRS Page 12 Mockup)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _containers.length,
                          itemBuilder: (context, index) {
                            final item = _containers[index];
                            return _buildContainerCard(item, settings);
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
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

  Widget _buildContainerCard(ContainerItem item, AppSettingsController settings) {
    final isDark = settings.isDarkMode;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OwnerContainerDetailsScreen(container: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                            color: isDark ? const Color(0xFF0B3A5A) : AppColors.skyLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.inventory_2_outlined, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.containerNo,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              item.type,
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildStatusBadge(item.status),
                  ],
                ),
                const SizedBox(height: 14),

                // Route (Current road to Destination)
                Row(
                  children: [
                    const Icon(Icons.trip_origin_rounded, size: 14, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.currentRoad}  ➔  ${item.destination}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Telemetry (ETA, Speed, Seal)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Flexible(child: _buildMiniInfo(Icons.timer_outlined, settings.tr('eta'), item.eta, textColor)),
                      const SizedBox(width: 6),
                      Flexible(child: _buildMiniInfo(Icons.speed_rounded, settings.tr('speed'), '${item.speedKmh.toInt()} km/h', textColor)),
                      const SizedBox(width: 6),
                      Flexible(
                        flex: 2,
                        child: _buildMiniInfo(
                          Icons.lock_outline_rounded,
                          'Seal',
                          item.sealStatus
                              .replaceAll('Closed & Secure ', 'Secure • ')
                              .replaceAll('(', '')
                              .replaceAll(')', ''),
                          item.sealStatus.contains('Secure') ? AppColors.successGreen : AppColors.alertRed,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    if (status.toLowerCase().contains('transit') || status.toLowerCase().contains('track') || status.toLowerCase().contains('active')) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF166534);
    } else if (status.toLowerCase().contains('delivered')) {
      bg = const Color(0xFFE0EDFB);
      fg = AppColors.primaryBlue;
    } else {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String title, String value, Color color, {int maxLines = 1}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1.5),
          child: Icon(icon, size: 14, color: AppColors.textMuted),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color, height: 1.15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
