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
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  List<Map<String, dynamic>> _getFilteredQueue() {
    return _allInspectionContainers.where((item) {
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
        final filteredQueue = _getFilteredQueue();

        final screens = [
          InspectorHomeScreen(
            dutyStation: currentInspector.dutyStation,
            officerName: currentInspector.fullName,
            badgeNo: currentInspector.badgeNo,
            queueFilter: _queueFilter,
            queue: filteredQueue,
            onFilterChanged: (filter) => setState(() => _queueFilter = filter),
            onSelectForInspection: _onSelectForInspection,
            onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            onNavigateToAlerts: () => setState(() => _currentIndex = 2),
          ),
          InspectorSealVerificationScreen(
            dutyStation: currentInspector.dutyStation,
            initialContainerId: _selectedContainerId,
            initialSealId: _selectedSealId,
            queue: _allInspectionContainers,
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
