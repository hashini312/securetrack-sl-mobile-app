import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../models/driver_models.dart';
import '../services/driver_api_service.dart';

class DriverNotificationsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const DriverNotificationsScreen({super.key, this.onBackToHome});

  @override
  State<DriverNotificationsScreen> createState() => _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  List<DriverNotificationModel> items = [];

  @override
  void initState() {
    super.initState();
    items = DriverApiService.getDriverNotifications();
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
        final mutedColor = isDark ? const Color(0xFF94A3B8) : AppColors.textMuted;
        final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: const Text('Notifications'),
            backgroundColor: AppColors.primaryBlue,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: cardColor,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Alerts & Updates',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time instructions from Customs Monitoring Office',
                      style: TextStyle(
                        fontSize: 12,
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: borderColor),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildNotificationCard(item, isDark, cardColor, textColor, mutedColor, borderColor);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(
    DriverNotificationModel item,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color borderColor,
  ) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    if (item.type == 'deviation') {
      icon = Icons.warning_amber_rounded;
      iconColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
      iconBg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
    } else if (item.type == 'weather') {
      icon = Icons.cloud_outlined;
      iconColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
      iconBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
    } else if (item.type == 'checkpoint') {
      icon = Icons.check_circle_outline_rounded;
      iconColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
      iconBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
    } else {
      icon = Icons.traffic_rounded;
      iconColor = isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C);
      iconBg = isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFEDD5);
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
            blurRadius: 6,
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
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.circle, size: 8, color: Color(0xFF2563EB)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
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
