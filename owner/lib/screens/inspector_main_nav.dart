import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../services/driver_api_service.dart';
import '../models/driver_models.dart';
import '../theme/app_theme.dart';
import '../widgets/inspector_app_drawer.dart';
import 'inspector_home_screen.dart';
import 'inspector_seal_verification_screen.dart';
import 'inspector_violations_screen.dart';
import 'inspector_profile_screen.dart';

class InspectorMainNav extends StatefulWidget {
  final int initialIndex;
  const InspectorMainNav({super.key, this.initialIndex = 0});

  @override
  State<InspectorMainNav> createState() => _InspectorMainNavState();
}

class _InspectorMainNavState extends State<InspectorMainNav> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentIndex;
  String _queueFilter = 'All';

  String _selectedContainerId = 'CONT-LK-001';
  String _selectedSealId = 'IOT-DEV-001';

  final List<Map<String, dynamic>> _allInspectionContainers = [
    // -----------------------------------------------------------------
    // Katunayake BOI / FTZ (Assigned to Inspector: Hasitha Dana - INSP-13)
    // -----------------------------------------------------------------
    {
      'id': 'CONT-LK-001',
      'destination': 'Katunayake BOI',
      'cargo': 'Industrial Electronics & Machinery',
      'weight': '24,500 kg',
      'status': 'Pending BOI Clearance',
      'seal': 'IOT-DEV-001 (TAG-12345)',
      'vehicle': 'cp-pt-2943',
      'haulier': 'Lanka Logistics Ltd',
      'driver': 'Uvindu Bandara',
      'route': 'Colombo Port Gate 01 ➔ Katunayake BOI',
      'risk': 'Low Risk (AEO Verified)',
      'riskColor': AppColors.successGreen,
    },
    {
      'id': 'CGO-1001',
      'destination': 'Katunayake FTZ',
      'cargo': 'Machinery Spare Parts & Sensors',
      'weight': '18,200 kg',
      'status': 'Seal Verification Required',
      'seal': 'IOT-DEV-002 (TAG-90821)',
      'vehicle': 'LL-8666',
      'haulier': 'Ceylon Freight Fleet',
      'driver': 'Dilshan',
      'route': 'Colombo Port Gate 04 ➔ Katunayake FTZ',
      'risk': 'Standard Risk',
      'riskColor': AppColors.warningOrange,
    },
    {
      'id': 'CGO-1004',
      'destination': 'Katunayake BOI',
      'cargo': 'Pharmaceutical Grade Reagents',
      'weight': '26,100 kg',
      'status': 'Pending BOI Clearance',
      'seal': 'IOT-DEV-004 (TAG-77112)',
      'vehicle': 'WP-CBE-9901',
      'haulier': 'Lanka Logistics Ltd',
      'driver': 'Roshen Alwis',
      'route': 'Colombo Port Holding Area ➔ Katunayake BOI',
      'risk': 'Low Risk (Cold-Chain Verified)',
      'riskColor': AppColors.successGreen,
    },
    {
      'id': 'CONT-LK-002',
      'destination': 'Katunayake BOI',
      'cargo': 'Precision Aircraft Tooling',
      'weight': '14,200 kg',
      'status': 'Cleared & Gate Pass Issued',
      'seal': 'IOT-DEV-010 (TAG-88231)',
      'vehicle': 'WP-NC-5541',
      'haulier': 'Ceylon Freight Fleet',
      'driver': 'Suranga Lakmal',
      'route': 'Colombo Port Gate 03 ➔ Katunayake BOI',
      'risk': 'Low Risk (Cleared)',
      'riskColor': AppColors.successGreen,
    },

    // -----------------------------------------------------------------
    // Biyagama FTZ / Export Zone (Assigned to Inspector: Saman Kumara - INSP-15)
    // -----------------------------------------------------------------
    {
      'id': 'CGO-1002',
      'destination': 'Biyagama FTZ',
      'cargo': 'Solar Inverters & Lithium Cells',
      'weight': '22,000 kg',
      'status': 'Seal Verification Required',
      'seal': 'IOT-DEV-003 (TAG-55441)',
      'vehicle': 'LC-2225',
      'haulier': 'Cargo Overseas Hauliers',
      'driver': 'Nimantha Bandara',
      'route': 'Peliyagoda Yard ➔ Biyagama FTZ',
      'risk': 'Standard Risk (Lithium Cells)',
      'riskColor': AppColors.warningOrange,
    },
    {
      'id': 'CONT-LK-003',
      'destination': 'Biyagama FTZ',
      'cargo': 'Textile & Apparel Raw Materials',
      'weight': '19,400 kg',
      'status': 'Pending FTZ Inward Clearance',
      'seal': 'IOT-DEV-008 (TAG-66190)',
      'vehicle': 'WP-ND-8192',
      'haulier': 'Lanka Logistics Ltd',
      'driver': 'Sunil Shantha',
      'route': 'Colombo Port Gate 02 ➔ Biyagama FTZ',
      'risk': 'Low Risk (AEO Verified)',
      'riskColor': AppColors.successGreen,
    },
    {
      'id': 'CGO-1003',
      'destination': 'Biyagama Export Zone',
      'cargo': 'Automotive Sub-assemblies',
      'weight': '12,800 kg',
      'status': 'Cleared & Gate Pass Issued',
      'seal': 'IOT-DEV-005 (TAG-33120)',
      'vehicle': 'PT-2943',
      'haulier': 'Ceylon Freight Fleet',
      'driver': 'Matheesha',
      'route': 'Peliyagoda Yard ➔ Biyagama Export Zone',
      'risk': 'Low Risk (Cleared)',
      'riskColor': AppColors.successGreen,
    },

    // -----------------------------------------------------------------
    // Orugodawatta Customs Yard (Assigned to Inspector: Kavindu Madushan - INSP-14)
    // -----------------------------------------------------------------
    {
      'id': 'CGO-1005',
      'destination': 'Orugodawatta Customs Yard',
      'cargo': 'Heavy Machinery & Hydraulic Parts',
      'weight': '28,300 kg',
      'status': 'Pending Yard Inspection',
      'seal': 'IOT-DEV-006 (TAG-44821)',
      'vehicle': 'WP-CAB-4412',
      'haulier': 'Ceylon Freight Fleet',
      'driver': 'Kusal Mendis',
      'route': 'Colombo Port Gate 02 ➔ Orugodawatta Customs Yard',
      'risk': 'Standard Risk',
      'riskColor': AppColors.warningOrange,
    },
    {
      'id': 'CGO-1006',
      'destination': 'Orugodawatta Customs Yard',
      'cargo': 'Consumer Electronics Consignment',
      'weight': '15,100 kg',
      'status': 'Seal Verification Required',
      'seal': 'IOT-DEV-007 (TAG-99011)',
      'vehicle': 'WP-DA-3119',
      'haulier': 'Cargo Overseas Hauliers',
      'driver': 'Kasun Rajitha',
      'route': 'Peliyagoda Yard ➔ Orugodawatta Customs Yard',
      'risk': 'Standard Risk (High Value)',
      'riskColor': AppColors.warningOrange,
    },
    {
      'id': 'CGO-1007',
      'destination': 'Orugodawatta Customs Yard',
      'cargo': 'Agricultural Fertilizers & Seeds',
      'weight': '21,000 kg',
      'status': 'Cleared & Gate Pass Issued',
      'seal': 'IOT-DEV-009 (TAG-11234)',
      'vehicle': 'WP-GA-7762',
      'haulier': 'Lanka Logistics Ltd',
      'driver': 'Pradeep Kumara',
      'route': 'Colombo Port Gate 01 ➔ Orugodawatta Customs Yard',
      'risk': 'Low Risk (Cleared)',
      'riskColor': AppColors.successGreen,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    final initialList = _getStationContainers(DriverApiService.currentInspectorNotifier.value.dutyStation);
    if (initialList.isNotEmpty) {
      _selectedContainerId = initialList[0]['id'] ?? 'CONT-LK-001';
      _selectedSealId = initialList[0]['seal'] ?? 'IOT-DEV-001';
    }
  }

  bool _matchesStation(Map<String, dynamic> item, String dutyStation) {
    final station = dutyStation.toLowerCase();
    final dest = (item['destination'] ?? '').toString().toLowerCase();
    final route = (item['route'] ?? '').toString().toLowerCase();

    if (station.contains('katunayake')) {
      return dest.contains('katunayake') || route.contains('katunayake');
    } else if (station.contains('biyagama')) {
      return dest.contains('biyagama') || route.contains('biyagama');
    } else if (station.contains('orugodawatta')) {
      return dest.contains('orugodawatta') || route.contains('orugodawatta');
    }
    return dest.contains(station) || route.contains(station);
  }

  List<Map<String, dynamic>> _getStationContainers(String dutyStation) {
    final list = _allInspectionContainers.where((c) => _matchesStation(c, dutyStation)).toList();
    return list.isNotEmpty ? list : _allInspectionContainers;
  }

  List<Map<String, dynamic>> _getFilteredQueue(String dutyStation) {
    final base = _getStationContainers(dutyStation);
    return base.where((item) {
      if (_queueFilter == 'All') return true;
      if (_queueFilter == 'Pending') return item['status'].toString().contains('Pending');
      if (_queueFilter == 'Seal Review') return item['status'].toString().contains('Seal');
      if (_queueFilter == 'Cleared') return item['status'].toString().contains('Cleared');
      return true;
    }).toList();
  }

  void _onSelectForInspection(String containerId, String sealId) {
    setState(() {
      _selectedContainerId = containerId;
      _selectedSealId = sealId;
      _currentIndex = 1; // Go to Seal Verification Screen
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ValueListenableBuilder<InspectorProfileModel>(
      valueListenable: DriverApiService.currentInspectorNotifier,
      builder: (context, currentInspector, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC);
        
        final stationContainers = _getStationContainers(currentInspector.dutyStation);
        final filteredQueue = _getFilteredQueue(currentInspector.dutyStation);

        final pendingCount = stationContainers.where((c) => !c['status'].toString().contains('Cleared')).length;
        final clearedCount = stationContainers.where((c) => c['status'].toString().contains('Cleared')).length;
        final alertsCount = stationContainers.where((c) => c['risk'].toString().contains('Standard') || c['risk'].toString().contains('High')).length;

        final screens = [
          InspectorHomeScreen(
            dutyStation: currentInspector.dutyStation,
            officerName: currentInspector.fullName,
            badgeNo: currentInspector.badgeNo,
            queueFilter: _queueFilter,
            queue: filteredQueue,
            activeCount: pendingCount,
            deliveredCount: clearedCount,
            alertsCount: alertsCount,
            onFilterChanged: (filter) => setState(() => _queueFilter = filter),
            onSelectForInspection: _onSelectForInspection,
            onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            onNavigateToAlerts: () => setState(() => _currentIndex = 2),
          ),
          InspectorSealVerificationScreen(
            dutyStation: currentInspector.dutyStation,
            initialContainerId: _selectedContainerId,
            initialSealId: _selectedSealId,
            queue: stationContainers,
            onClearanceCompleted: () => setState(() => _currentIndex = 0),
          ),
          InspectorViolationsScreen(
            containerId: _selectedContainerId,
            officerName: '${currentInspector.fullName} (${currentInspector.badgeNo})',
          ),
          InspectorProfileScreen(
            officerName: currentInspector.fullName,
            badgeNo: currentInspector.badgeNo,
            email: currentInspector.email,
            dutyStation: currentInspector.dutyStation,
            intercom: currentInspector.phone,
            onBackToHome: () => setState(() => _currentIndex = 0),
            onStationChanged: (newStation, newIntercom) {
              setState(() {
                final updated = InspectorProfileModel(
                  id: currentInspector.id,
                  username: currentInspector.username,
                  email: currentInspector.email,
                  fullName: currentInspector.fullName,
                  badgeNo: currentInspector.badgeNo,
                  dutyStation: newStation,
                  phone: newIntercom,
                  role: currentInspector.role,
                );
                DriverApiService.currentInspectorNotifier.value = updated;
                
                // Update selection to this station's first container
                final newContainers = _getStationContainers(newStation);
                if (newContainers.isNotEmpty) {
                  _selectedContainerId = newContainers[0]['id'] ?? 'CONT-LK-001';
                  _selectedSealId = newContainers[0]['seal'] ?? 'IOT-DEV-001';
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.successGreen,
                  content: Text('Terminal Station updated to $newStation'),
                ),
              );
            },
          ),
        ];

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: bgColor,
          drawer: InspectorAppDrawer(
            currentIndex: _currentIndex,
            onSelectTab: (index) => setState(() => _currentIndex = index),
          ),
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            indicatorColor: isDark ? const Color(0xFF0B3A5A) : const Color(0xFFE0EDFB),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: AppColors.primaryBlue),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.qr_code_scanner_outlined),
                selectedIcon: Icon(Icons.qr_code_scanner, color: AppColors.primaryBlue),
                label: 'Smart Seal',
              ),
              NavigationDestination(
                icon: Icon(Icons.warning_amber_rounded),
                selectedIcon: Icon(Icons.warning_rounded, color: AppColors.primaryBlue),
                label: 'Incidents',
              ),
              NavigationDestination(
                icon: Icon(Icons.badge_outlined),
                selectedIcon: Icon(Icons.badge, color: AppColors.primaryBlue),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
