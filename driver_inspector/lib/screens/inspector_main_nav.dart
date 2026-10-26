import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
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

  final String _officerName = 'Hasitha Dana (INSP-13)';
  String _dutyStation = 'Katunayake BOI';
  String _intercom = '+94 11 243 2191 (Ext 8941)';
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
      'vehicle': 'WP-CAD-1234',
      'haulier': 'Lanka Logistics Ltd',
      'driver': 'Sunil Perera',
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
      'vehicle': 'WP-CAR-5678',
      'haulier': 'Ceylon Freight Fleet',
      'driver': 'Kamal Silva',
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
      'vehicle': 'WP-CBE-9901 (Ashok Leyland)',
      'haulier': 'Lanka Logistics Ltd',
      'driver': 'Roshen Alwis',
      'route': 'Colombo Port Gate 01 ➔ Katunayake BOI',
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
      'vehicle': 'WP LC-2225 (Tata Prima)',
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
      'vehicle': 'WP-GA-3412 (Volvo FH16)',
      'haulier': 'Ceylon Freight Fleet',
      'driver': 'Ruwan Jayawardena',
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
    final station = _dutyStation.toLowerCase();
    var list = _allInspectionContainers;
    if (station.contains('biyagama')) {
      list = _allInspectionContainers.where((c) =>
        c['destination'].toString().toLowerCase().contains('biyagama') ||
        c['route'].toString().toLowerCase().contains('biyagama')
      ).toList();
    } else if (station.contains('katunayake') || station.contains('boi')) {
      list = _allInspectionContainers.where((c) =>
        c['destination'].toString().toLowerCase().contains('katunayake') ||
        c['route'].toString().toLowerCase().contains('katunayake') ||
        c['status'].toString().toLowerCase().contains('boi')
      ).toList();
    }

    if (_queueFilter == 'Pending') {
      return list.where((c) => !c['status'].toString().contains('Cleared')).toList();
    } else if (_queueFilter == 'Seal Review') {
      return list.where((c) => c['status'].toString().contains('Seal')).toList();
    } else if (_queueFilter == 'Cleared') {
      return list.where((c) => c['status'].toString().contains('Cleared')).toList();
    }
    return list;
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Customs Inspection Portal';
      case 1:
        return 'Smart Seal Terminal';
      case 2:
        return 'Tamper & Incident Logger';
      case 3:
        return 'Customs Officer Profile';
      default:
        return 'Customs Inspector Portal';
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

        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              setState(() => _currentIndex = 0);
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: bgColor,
            drawer: InspectorAppDrawer(
              currentIndex: _currentIndex,
              onSelectTab: (index) {
                setState(() => _currentIndex = index);
              },
            ),
            appBar: _currentIndex == 0
                ? null
                : AppBar(
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      tooltip: 'Back to Dashboard',
                      onPressed: () => setState(() => _currentIndex = 0),
                    ),
                    title: Text(
                      _getPageTitle(),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'INSP-13',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            body: IndexedStack(
              index: _currentIndex,
              children: [
                InspectorHomeScreen(
                  dutyStation: _dutyStation,
                  officerName: _officerName,
                  queueFilter: _queueFilter,
                  queue: _getFilteredQueue(),
                  onFilterChanged: (filter) => setState(() => _queueFilter = filter),
                  onSelectForInspection: (containerId, sealId) {
                    setState(() {
                      _selectedContainerId = containerId;
                      _selectedSealId = sealId;
                      _currentIndex = 1;
                    });
                  },
                  onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                  onNavigateToAlerts: () => setState(() => _currentIndex = 2),
                ),
                InspectorSealVerificationScreen(
                  dutyStation: _dutyStation,
                  initialContainerId: _selectedContainerId,
                  initialSealId: _selectedSealId,
                  queue: _getFilteredQueue(),
                  onClearanceCompleted: () {
                    setState(() {
                      final idx = _allInspectionContainers.indexWhere((c) => c['id'] == _selectedContainerId);
                      if (idx != -1) {
                        _allInspectionContainers[idx]['status'] = 'Cleared & Gate Pass Issued';
                        _allInspectionContainers[idx]['riskColor'] = AppColors.successGreen;
                      }
                    });
                  },
                ),
                InspectorViolationsScreen(
                  officerName: _officerName,
                  containerId: _selectedContainerId,
                ),
                InspectorProfileScreen(
                  officerName: _officerName,
                  dutyStation: _dutyStation,
                  intercom: _intercom,
                  onStationChanged: (newStation, newIntercom) {
                    setState(() {
                      _dutyStation = newStation;
                      _intercom = newIntercom;
                    });
                  },
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner_rounded),
                  activeIcon: Icon(Icons.lock_rounded),
                  label: 'Smart Seal',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.warning_amber_rounded),
                  activeIcon: Icon(Icons.report_problem_rounded),
                  label: 'Incidents',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.badge_outlined),
                  activeIcon: Icon(Icons.badge_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
