import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../models/driver_models.dart';
import '../services/driver_api_service.dart';

class DriverTripDetailsScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;
  const DriverTripDetailsScreen({super.key, this.onBackToHome});

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

        return ValueListenableBuilder<DriverTripModel>(
          valueListenable: DriverApiService.currentTripNotifier,
          builder: (context, trip, _) {
            final isPlanned = trip.status.toUpperCase() == 'PLANNED';
            final isCompleted = trip.status.toUpperCase() == 'COMPLETED';

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                title: Text(
                  'Trip Details',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
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
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container Information Card (SRS Page 11 Mockup)
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Container Information',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPlanned
                                      ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))
                                      : (isCompleted
                                          ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE))
                                          : (isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7))),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  trip.status,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isPlanned
                                        ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706))
                                        : (isCompleted
                                            ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8))
                                            : (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF16A34A))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildInfoCol('Container ID', trip.containerNo, textColor, mutedColor)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildInfoCol('Seal Status', trip.sealStatus, textColor, mutedColor)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _buildInfoCol('Weight', trip.weight, textColor, mutedColor)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildInfoCol('Type', trip.type, textColor, mutedColor)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Route Information Card (SRS Page 11 Mockup)
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route Information',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.circle, color: Color(0xFF38BDF8), size: 14),
                                  Container(width: 2, height: 42, color: borderColor),
                                  const Icon(Icons.location_on, color: Color(0xFF16A34A), size: 18),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Start Location', style: GoogleFonts.poppins(fontSize: 11, color: mutedColor)),
                                    Text(
                                      trip.startLocation,
                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                    ),
                                    Text(
                                      isPlanned ? 'Departure: Scheduled' : 'Started: Today at 10:15 AM',
                                      style: GoogleFonts.poppins(fontSize: 11, color: mutedColor),
                                    ),
                                    const SizedBox(height: 14),
                                    Text('Destination', style: GoogleFonts.poppins(fontSize: 11, color: mutedColor)),
                                    Text(
                                      trip.destination,
                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                    ),
                                    Text(
                                      isCompleted ? 'Arrived & Cleared' : 'Expected: Today at 11:00 AM',
                                      style: GoogleFonts.poppins(fontSize: 11, color: mutedColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Trip Progress Card (SRS Page 11 Mockup)
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trip Progress',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricBox(Icons.navigation_outlined, trip.distanceLeft, 'Distance Left', const Color(0xFF38BDF8), textColor, mutedColor),
                              _buildMetricBox(Icons.access_time_rounded, trip.eta, 'ETA', const Color(0xFF16A34A), textColor, mutedColor),
                              _buildMetricBox(
                                Icons.check_circle_outline,
                                isPlanned ? 'Planned' : (isCompleted ? 'Arrived' : 'On Track'),
                                'Status',
                                const Color(0xFF0D9488),
                                textColor,
                                mutedColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Completed', style: GoogleFonts.poppins(fontSize: 12, color: mutedColor)),
                              Text(
                                '${trip.progressPercent}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: trip.progressPercent / 100,
                              minHeight: 8,
                              backgroundColor: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppColors.skyBlue : AppColors.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCol(String label, String value, Color textColor, Color mutedColor, {int maxLines = 2}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 11, color: mutedColor),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox(IconData icon, String value, String label, Color color, Color textColor, Color mutedColor) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: mutedColor),
        ),
      ],
    );
  }
}
