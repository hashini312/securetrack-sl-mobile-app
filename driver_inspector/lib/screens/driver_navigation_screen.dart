import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../models/driver_models.dart';
import '../services/driver_api_service.dart';
import '../services/app_settings.dart';

class DriverNavigationScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const DriverNavigationScreen({super.key, this.onBackToHome});

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  bool isDeviated = false;

  final List<LatLng> katunayakeRoute = const [
    LatLng(6.9497, 79.8433), // Colombo Port
    LatLng(6.9426, 79.8623), // Port Access / Ingurukade
    LatLng(6.9554, 79.8827), // Peliyagoda Flyover
    LatLng(6.9732, 79.8942), // Kelaniya / Thorana Junction
    LatLng(7.0036, 79.9027), // Mahabage
    LatLng(7.0555, 79.8797), // Ja-Ela Interchange
    LatLng(7.1228, 79.8732), // Seeduwa
    LatLng(7.1706, 79.8837), // Katunayake BOI / FTZ
  ];

  final List<LatLng> katunayakeDeviated = const [
    LatLng(6.9497, 79.8433),
    LatLng(6.9426, 79.8623),
    LatLng(6.9554, 79.8827),
    LatLng(7.0036, 79.9027),
    LatLng(7.0555, 79.8797),
    LatLng(7.0650, 79.9200), // Deviated east
  ];

  final List<LatLng> biyagamaRoute = const [
    LatLng(6.9497, 79.8433), // Colombo Port
    LatLng(6.9426, 79.8623), // Port Access
    LatLng(6.9554, 79.8827), // Peliyagoda Flyover
    LatLng(6.9732, 79.8942), // Kelaniya
    LatLng(6.9580, 79.9350), // Kelani River Bank
    LatLng(6.9450, 79.9650), // Biyagama Road
    LatLng(6.9405, 79.9850), // Biyagama FTZ Gate
  ];

  final List<LatLng> biyagamaDeviated = const [
    LatLng(6.9497, 79.8433),
    LatLng(6.9426, 79.8623),
    LatLng(6.9554, 79.8827),
    LatLng(6.9732, 79.8942),
    LatLng(6.9150, 79.9400), // Deviated south
  ];

  void _onSimulateDeviation() async {
    setState(() {
      isDeviated = true;
    });

    final currentContainer = DriverApiService.currentTripNotifier.value.containerNo;
    await DriverApiService.simulateDeviation(currentContainer);

    if (mounted) {
      final isDark = AppSettingsController.instance.isDarkMode;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2A0D15) : const Color(0xFFFFF1F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDark ? const Color(0xFF9F1239) : const Color(0xFFFECDD3)),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Color(0xFFE11D48), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Route Deviation Alert!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFFECDD3) : const Color(0xFF9F1239),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'GPS geofence corridor exceeded by 2.3 km for container $currentContainer! An automated Tamper & Deviation alert has been sent to Sri Lanka Customs Monitoring Center.',
            style: TextStyle(
              color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFF881337),
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Acknowledge Warning',
                style: TextStyle(
                  color: isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
        final bgColor = isDark ? AppColors.darkBackground : Colors.white;
        final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

        return ValueListenableBuilder<DriverTripModel>(
          valueListenable: DriverApiService.currentTripNotifier,
          builder: (context, trip, _) {
            final isBiyagama = trip.destination.toLowerCase().contains('biyagama');
            final activeRoute = isBiyagama ? biyagamaRoute : katunayakeRoute;
            final activeDeviated = isBiyagama ? biyagamaDeviated : katunayakeDeviated;
            final truckPoint = isDeviated
                ? (isBiyagama ? const LatLng(6.9150, 79.9400) : const LatLng(7.0650, 79.9200))
                : (isBiyagama ? const LatLng(6.9580, 79.9350) : const LatLng(7.0555, 79.8797));

            return Scaffold(
              backgroundColor: bgColor,
              body: SafeArea(
                child: Column(
                  children: [
                    // Top Navigation Info Bar (SRS Page 10 Mockup)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue, size: 20),
                            tooltip: 'Back to Dashboard',
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else if (widget.onBackToHome != null) {
                                widget.onBackToHome!();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Destination', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                                    Text(trip.destination, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('ETA: ${trip.eta}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue)),
                                    Text('${trip.distanceLeft} remaining', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: borderColor),

                    // Map with Navigation View (SRS Page 10 Mockup)
                    Expanded(
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: truckPoint,
                              initialZoom: 12.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.securetrack.driver',
                                tileBuilder: isDark ? darkModeTileBuilder : null,
                              ),
                              // Corridor Route
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: isDeviated ? activeDeviated : activeRoute,
                                    strokeWidth: 5.0,
                                    color: isDeviated ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB)),
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  // Truck Location Marker with Navigation Arrow
                                  Marker(
                                    point: truckPoint,
                                    width: 50,
                                    height: 50,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDeviated ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 28),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Warning Banner if deviated
                          if (isDeviated)
                            Positioned(
                              top: 14,
                              left: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'ROUTE DEVIATION DETECTED: 2.3 KM OFF CORRIDOR (${trip.containerNo})',
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Next Turn Prompt (SRS Page 10 Mockup)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border(top: BorderSide(color: borderColor)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F2B48) : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.turn_right_rounded, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isBiyagama ? 'Next Waypoint in 800 m' : 'Next Waypoint in 1.2 km', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                                const SizedBox(height: 2),
                                Text(
                                  isBiyagama
                                      ? 'Continue along Colombo-Biyagama Corridor (B214)'
                                      : 'Continue along Colombo-Katunayake Corridor (A3)',
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // "Simulate Deviation" Button (SRS Page 10 Mockup)
                    Container(
                      color: cardColor,
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _onSimulateDeviation,
                          icon: const Icon(Icons.alt_route_rounded),
                          label: Text(isDeviated ? 'Route Deviation Active' : 'Simulate Deviation', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDeviated ? const Color(0xFFDC2626) : AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
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
}
