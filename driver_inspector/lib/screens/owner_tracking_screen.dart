import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_settings.dart';
import '../services/api_service.dart';

class OwnerTrackingScreen extends StatefulWidget {
  final ContainerItem? initialContainer;
  final VoidCallback? onBackToHome;

  const OwnerTrackingScreen({super.key, this.initialContainer, this.onBackToHome});

  @override
  State<OwnerTrackingScreen> createState() => _OwnerTrackingScreenState();
}

class _OwnerTrackingScreenState extends State<OwnerTrackingScreen> {
  late ContainerItem container;
  final MapController _mapController = MapController();

  // Planned corridor coordinates (Katunayake to Port of Colombo)
  final List<LatLng> plannedCorridor = [
    const LatLng(6.9497, 79.8433), // Colombo Port Gate 04
    const LatLng(6.9426, 79.8623), // Port Access / Ingurukade
    const LatLng(6.9554, 79.8827), // Peliyagoda Flyover
    const LatLng(6.9732, 79.8942), // Kelaniya / Thorana Junction
    const LatLng(7.0036, 79.9027), // Mahabage
    const LatLng(7.0555, 79.8797), // Ja-Ela Interchange (Current Truck)
    const LatLng(7.1228, 79.8732), // Seeduwa
    const LatLng(7.1706, 79.8837), // Katunayake BOI / FTZ (Destination)
  ];

  List<ContainerItem> _availableContainers = [];

  @override
  void initState() {
    super.initState();
    container = widget.initialContainer ??
        ContainerItem(
          id: '1',
          containerNo: 'CONT-LK-001',
          destination: 'Katunayake BOI',
          currentRoad: 'A3 Highway, Ja-Ela',
          eta: '20 mins',
          status: 'In Transit',
          distanceLeftKm: 14.2,
          speedKmh: 58.0,
          progressPercent: 62,
          latitude: 7.0555,
          longitude: 79.8797,
        );
    ApiService.currentOwnerNotifier.addListener(_onOwnerChanged);
    _loadAvailableContainers();
  }

  @override
  void dispose() {
    ApiService.currentOwnerNotifier.removeListener(_onOwnerChanged);
    super.dispose();
  }

  void _onOwnerChanged() {
    _loadAvailableContainers();
  }

  void _loadAvailableContainers() async {
    final list = await ApiService.getOwnerContainers();
    if (mounted) {
      setState(() {
        _availableContainers = list;
        if (list.isNotEmpty && widget.initialContainer == null) {
          if (!list.any((c) => c.containerNo == container.containerNo)) {
            container = list.first;
            _recenterOnTruck();
          }
        }
      });
    }
  }

  void _showContainerPicker(BuildContext context, Color textColor, Color cardColor, Color borderColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Container to Track', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 12),
            ..._availableContainers.map((c) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              title: Text(c.containerNo, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              subtitle: Text('${c.destination} ? ${c.status}'),
              trailing: c.containerNo == container.containerNo ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue) : null,
              onTap: () {
                setState(() {
                  container = c;
                });
                _recenterOnTruck();
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _recenterOnTruck() {
    _mapController.move(LatLng(container.latitude, container.longitude), 12.5);
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

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              // 1. FULL-SCREEN INTERACTIVE MAP (Prominent & Clear)
              Positioned.fill(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(container.latitude, container.longitude),
                    initialZoom: 11.8,
                    minZoom: 8.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.securetrack.app',
                      tileBuilder: isDark ? darkModeTileBuilder : null,
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: plannedCorridor,
                          strokeWidth: 4.5,
                          color: isDark ? const Color(0xFF38BDF8) : AppColors.primaryBlue,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        // Origin: Colombo Port Gate 04
                        Marker(
                          point: const LatLng(6.9497, 79.8433),
                          width: 38,
                          height: 38,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryBlue, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                              ],
                            ),
                            child: const Icon(Icons.warehouse_rounded, color: AppColors.primaryBlue, size: 20),
                          ),
                        ),
                        // Current Truck Position (Animated pulse appearance)
                        Marker(
                          point: LatLng(container.latitude, container.longitude),
                          width: 50,
                          height: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 20),
                              ),
                            ],
                          ),
                        ),
                        // Destination: Katunayake BOI
                        Marker(
                          point: const LatLng(7.1706, 79.8837),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFEF4444), width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                              ],
                            ),
                            child: const Icon(Icons.flag_rounded, color: Color(0xFFEF4444), size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. FLOATING TOP APP BAR (Responsive & Glassmorphic)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface.withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
                            tooltip: 'Back',
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else if (widget.onBackToHome != null) {
                                widget.onBackToHome!();
                              }
                            },
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _showContainerPicker(context, textColor, cardColor, borderColor),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        container.containerNo,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.primaryBlue),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Live GPS Corridor • ${container.destination}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              container.status,
                              style: const TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. MAP CONTROL BUTTONS (Zoom & Recenter)
              Positioned(
                right: 16,
                bottom: 220,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in',
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      elevation: 4,
                      onPressed: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(_mapController.camera.center, currentZoom + 1);
                      },
                      child: const Icon(Icons.add, size: 20),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out',
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      elevation: 4,
                      onPressed: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(_mapController.camera.center, currentZoom - 1);
                      },
                      child: const Icon(Icons.remove, size: 20),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'recenter',
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      onPressed: _recenterOnTruck,
                      child: const Icon(Icons.my_location_rounded, size: 20),
                    ),
                  ],
                ),
              ),

              // 4. ELEGANT DRAGGABLE BOTTOM SHEET FOR TRACKING DETAILS
              // Leaves 70%+ of the screen clear for the map, expandable upon swipe
              DraggableScrollableSheet(
                initialChildSize: 0.28,
                minChildSize: 0.16,
                maxChildSize: 0.72,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Quick Glance Status Row (Always visible in collapsed view)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
                                      SizedBox(width: 6),
                                      Text(
                                        'Live GPS Connected',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    container.currentRoad,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F2B48) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'ETA ${container.eta}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Metric Badges (ETA, Distance Left, Speed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Flexible(child: _buildMetricItem(Icons.speed_rounded, 'Speed', '${container.speedKmh.toInt()} km/h', textColor)),
                              const SizedBox(width: 6),
                              Flexible(child: _buildMetricItem(Icons.alt_route_rounded, 'Distance', '${container.distanceLeftKm.toStringAsFixed(1)} km', textColor)),
                              const SizedBox(width: 6),
                              Flexible(
                                flex: 2,
                                child: _buildMetricItem(
                                  Icons.lock_rounded,
                                  'Seal',
                                  container.sealStatus.contains('Secure') ? 'Secure (TAG-12345)' : 'Tampered',
                                  container.sealStatus.contains('Secure') ? const Color(0xFF16A34A) : AppColors.alertRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Progress Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Corridor Completion', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            Text('${container.progressPercent}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: container.progressPercent / 100,
                            minHeight: 6,
                            backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppColors.skyBlue : AppColors.primaryBlue),
                          ),
                        ),

                        const SizedBox(height: 18),
                        Divider(height: 1, color: borderColor),
                        const SizedBox(height: 14),

                        // Route Checkpoint Corridor Details (Visible when dragged up)
                        Text(
                          'Authorized Corridor Milestones',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 12),

                        _buildMilestone(
                          icon: Icons.warehouse_rounded,
                          title: 'Colombo Port (Gate 04)',
                          time: 'Departed: 09:30 AM',
                          isPassed: true,
                          isLast: false,
                          textColor: textColor,
                          borderColor: borderColor,
                        ),
                        _buildMilestone(
                          icon: Icons.local_shipping_rounded,
                          title: container.currentRoad,
                          time: 'Current Location • In Transit',
                          isPassed: true,
                          isCurrent: true,
                          isLast: false,
                          textColor: textColor,
                          borderColor: borderColor,
                        ),
                        _buildMilestone(
                          icon: Icons.flag_rounded,
                          title: '${container.destination} (Security Zone)',
                          time: 'Expected: 10:15 AM (ETA 20 mins)',
                          isPassed: false,
                          isLast: true,
                          textColor: textColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMilestone({
    required IconData icon,
    required String title,
    required String time,
    required bool isPassed,
    bool isCurrent = false,
    required bool isLast,
    required Color textColor,
    required Color borderColor,
  }) {
    final color = isCurrent
        ? const Color(0xFF10B981)
        : (isPassed ? AppColors.primaryBlue : const Color(0xFF94A3B8));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            if (!isLast) Container(width: 2, height: 32, color: borderColor),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
