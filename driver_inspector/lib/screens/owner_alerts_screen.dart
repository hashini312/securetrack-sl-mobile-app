import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import 'owner_container_details_screen.dart';

class OwnerAlertsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const OwnerAlertsScreen({super.key, this.onBackToHome});

  @override
  State<OwnerAlertsScreen> createState() => _OwnerAlertsScreenState();
}

class _OwnerAlertsScreenState extends State<OwnerAlertsScreen> {
  String selectedFilter = 'All';
  List<AlertNotificationItem> alerts = [];

  @override
  void initState() {
    super.initState();
    ApiService.currentOwnerNotifier.addListener(_onOwnerChanged);
    _loadAlerts();
  }

  @override
  void dispose() {
    ApiService.currentOwnerNotifier.removeListener(_onOwnerChanged);
    super.dispose();
  }

  void _onOwnerChanged() {
    _loadAlerts();
  }

  void _loadAlerts() {
    if (mounted) {
      setState(() {
        alerts = ApiService.getOwnerAlerts();
      });
    } else {
      alerts = ApiService.getOwnerAlerts();
    }
  }

  void _openContainerDetails(String containerNo) async {
    final containers = await ApiService.getOwnerContainers();
    final target = containers.firstWhere(
      (c) => c.containerNo.toLowerCase().trim() == containerNo.toLowerCase().trim(),
      orElse: () => containers.first,
    );
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OwnerContainerDetailsScreen(container: target),
        ),
      );
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
        final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

        final filteredAlerts = alerts.where((a) {
          if (selectedFilter == 'All') return true;
          if (selectedFilter == 'Critical') return a.type == 'Critical' || a.type == 'Warning';
          if (selectedFilter == 'Delivered') return a.type == 'Success';
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: const Text('Alerts & Notifications'),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              tooltip: 'Back',
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else if (widget.onBackToHome != null) {
                  widget.onBackToHome!();
                }
              },
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Tabs (SRS Page 13 Mockup: All | Critical | Delivered)
              Container(
                color: isDark ? AppColors.darkSurface : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    _buildFilterChip('All', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Critical', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Delivered', isDark),
                  ],
                ),
              ),
              Divider(height: 1, color: borderColor),

              // Alerts List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredAlerts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final alert = filteredAlerts[index];
                    return _buildAlertCard(alert, cardColor, textColor, borderColor, isDark);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.skyBlue : AppColors.primaryBlue)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(AlertNotificationItem alert, Color cardColor, Color textColor, Color borderColor, bool isDark) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    if (alert.type == 'Critical') {
      icon = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFDC2626);
      iconBg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
    } else if (alert.type == 'Warning') {
      icon = Icons.alt_route_rounded;
      iconColor = const Color(0xFFD97706);
      iconBg = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
    } else if (alert.type == 'Success') {
      icon = Icons.check_circle_outline_rounded;
      iconColor = const Color(0xFF16A34A);
      iconBg = isDark ? const Color(0xFF052E16) : const Color(0xFFDCFCE7);
    } else {
      icon = Icons.notifications_none_rounded;
      iconColor = const Color(0xFF2563EB);
      iconBg = isDark ? const Color(0xFF172554) : const Color(0xFFDBEAFE);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const Icon(Icons.circle, size: 8, color: Color(0xFF2563EB)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), height: 1.3),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      alert.timeAgo,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    TextButton(
                      onPressed: () => _openContainerDetails(alert.containerNo),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 20),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
