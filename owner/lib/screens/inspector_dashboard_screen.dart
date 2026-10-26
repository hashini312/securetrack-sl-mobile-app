import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../services/driver_api_service.dart';
import '../models/driver_models.dart';
import '../widgets/inspector_app_drawer.dart';
import 'driver_login_screen.dart';

class InspectorDashboardScreen extends StatefulWidget {
  const InspectorDashboardScreen({super.key});

  @override
  State<InspectorDashboardScreen> createState() => _InspectorDashboardScreenState();
}

class _InspectorDashboardScreenState extends State<InspectorDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final TextEditingController _containerCtrl = TextEditingController(text: 'CONT-LK-001');
  final TextEditingController _sealCtrl = TextEditingController(text: 'IOT-DEV-001');
  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _violationDescCtrl = TextEditingController();

  String _officerName = 'Hasitha Dana (INSP-13)';
  String _dutyStation = 'Katunayake BOI';
  String _intercom = '+94 11 243 2191 (Ext 8941)';

  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = true;
  String _selectedViolationType = 'Tamper Sensor Triggered';
  String _selectedSeverity = 'High Priority';
  bool _sealIntegrityChecked = true;
  bool _weightMatchChecked = true;
  bool _manifestMatchChecked = true;
  String _queueFilter = 'All';

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

  List<Map<String, dynamic>> _getStationFilteredQueue() {
    final station = _dutyStation.toLowerCase();
    if (station.contains('biyagama')) {
      return _allInspectionContainers.where((c) =>
        c['destination'].toString().toLowerCase().contains('biyagama') ||
        c['route'].toString().toLowerCase().contains('biyagama')
      ).map((c) => {
        ...c,
        'status': c['id'] == 'CGO-1003' ? 'Cleared & Gate Pass Issued' : 'Pending Biyagama FTZ Inward Clearance',
      }).toList();
    } else if (station.contains('katunayake') || station.contains('boi')) {
      return _allInspectionContainers.where((c) =>
        c['destination'].toString().toLowerCase().contains('katunayake') ||
        c['route'].toString().toLowerCase().contains('katunayake') ||
        c['status'].toString().toLowerCase().contains('boi')
      ).map((c) => {
        ...c,
        'status': c['status'].toString().contains('Seal') ? 'Seal Verification Required' : 'Pending BOI Inward Clearance',
      }).toList();
    } else if (station.contains('colombo') || station.contains('orugodawatta')) {
      // Orugodawatta is the Departure Gate for both Katunayake and Biyagama corridors
      return _allInspectionContainers.where((c) =>
        c['id'] != 'CGO-1003' // Exclude already delivered container
      ).map((c) => {
        ...c,
        'status': 'Pending Orugodawatta Departure Arming',
      }).toList();
    }
    return _allInspectionContainers;
  }

  @override
  void initState() {
    super.initState();
    final insp = DriverApiService.currentInspectorNotifier.value;
    _officerName = '${insp.fullName} (${insp.badgeNo})';
    _dutyStation = insp.dutyStation;
    _intercom = insp.phone;

    final stationQueue = _getStationFilteredQueue();
    if (stationQueue.isNotEmpty) {
      _containerCtrl.text = stationQueue.first['id'];
      _sealCtrl.text = stationQueue.first['seal'];
    }
  }

  final List<Map<String, String>> _recentIncidents = [
    {
      'container': 'CONT-LK-001',
      'category': 'Tamper Sensor Triggered',
      'severity': 'High Priority',
      'time': '10 mins ago',
      'officer': 'Hasitha Dana (INSP-13)',
      'status': 'Under Review',
    },
  ];

  @override
  void dispose() {
    _containerCtrl.dispose();
    _sealCtrl.dispose();
    _notesCtrl.dispose();
    _violationDescCtrl.dispose();
    super.dispose();
  }

  void _lockContainer() async {
    setState(() => _isLoading = true);
    final success = await DriverApiService.lockContainer(
      _containerCtrl.text.trim(),
      _sealCtrl.text.trim(),
    );
    setState(() {
      _isLoading = false;
      _isSuccess = success;
      _statusMessage = success
          ? 'SUCCESS (UC-01): Container ${_containerCtrl.text} electronically locked with ${_sealCtrl.text}. Departure manifest initialized in Customs Backend.'
          : 'Failed to communicate with Customs Backend. Please verify credentials.';
    });
  }

  void _unlockContainer() async {
    setState(() => _isLoading = true);
    final success = await DriverApiService.unlockContainer(
      _containerCtrl.text.trim(),
      _sealCtrl.text.trim(),
    );
    setState(() {
      _isLoading = false;
      _isSuccess = success;
      _statusMessage = success
          ? 'CLEARED (UC-03): Container ${_containerCtrl.text} authorized and electronic seal released. Clearance Gate Pass #SLC-GP-90821 recorded.'
          : 'Verification failed. Security alert maintained on seal.';
    });
  }

  void _submitViolationReport() {
    if (_violationDescCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter violation details')),
      );
      return;
    }

    final isDark = AppSettingsController.instance.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.report_problem_rounded, color: AppColors.alertRed),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Confirm Violation Log',
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
          'Log incident report for Container ${_containerCtrl.text} with category "$_selectedViolationType" ($_selectedSeverity)?\n\nThis will dispatch immediate alerts to SL Customs Head Office.',
          style: GoogleFonts.poppins(fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _recentIncidents.insert(0, {
                  'container': _containerCtrl.text,
                  'category': _selectedViolationType,
                  'severity': _selectedSeverity,
                  'time': 'Just now',
                  'officer': _officerName,
                  'status': 'Logged to Central Command',
                });
                _violationDescCtrl.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.alertRed,
                  content: Text('🚨 Customs Incident Report successfully logged and dispatched.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
            child: const Text('Confirm & Dispatch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditInspectorDialog(BuildContext context, bool isDark, Color textColor, Color cardColor, Color borderColor) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: _officerName);
    final stationCtrl = TextEditingController(text: _dutyStation);
    final phoneCtrl = TextEditingController(text: _intercom);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                            color: isDark ? const Color(0xFF0B3A5A) : const Color(0xFFE0EDFB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryBlue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Edit Officer Details',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Update active terminal post and officer communication details.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                Text('Inspector Officer Name', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.textMuted),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Officer name cannot be empty' : null,
                ),
                const SizedBox(height: 14),

                Text('Assigned Terminal / Gate', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: stationCtrl,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textMuted),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Duty station cannot be empty' : null,
                ),
                const SizedBox(height: 14),

                Text('Control Room Intercom / Phone', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: phoneCtrl,
                  style: GoogleFonts.poppins(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.textMuted),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Intercom cannot be empty' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          _officerName = nameCtrl.text.trim();
                          _dutyStation = stationCtrl.text.trim();
                          _intercom = phoneCtrl.text.trim();
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF16A34A),
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Inspector details updated successfully!'),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: Text('Save Officer Record', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

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
            // When in Dashboard (Tab 0), NO AppBar is shown, maintaining complete visual consistency with Owner and Driver
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
            body: _buildCurrentTab(isDark, cardColor, textColor, borderColor, settings),
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

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Customs Inspection Portal';
      case 1:
        return 'Smart Seal Terminal (UC-01/03)';
      case 2:
        return 'Tamper & Incident Logger';
      case 3:
        return 'Customs Officer Profile';
      default:
        return 'Customs Inspector Portal';
    }
  }

  Widget _buildCurrentTab(bool isDark, Color cardColor, Color textColor, Color borderColor, AppSettingsController settings) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardAndQueueTab(cardColor, textColor, borderColor, isDark, settings);
      case 1:
        return _buildSmartSealTab(cardColor, textColor, borderColor, isDark);
      case 2:
        return _buildViolationTab(cardColor, textColor, borderColor, isDark);
      case 3:
        return _buildInspectorProfileTab(cardColor, textColor, borderColor, isDark, settings);
      default:
        return _buildDashboardAndQueueTab(cardColor, textColor, borderColor, isDark, settings);
    }
  }

  /// TAB 0: Modern Customs Inspection Dashboard & Queue (100% matched to Owner and Driver Design Signature)
  Widget _buildDashboardAndQueueTab(Color cardColor, Color textColor, Color borderColor, bool isDark, AppSettingsController settings) {
    final stationQueue = _getStationFilteredQueue();
    final filteredQueue = stationQueue.where((item) {
      if (_queueFilter == 'All') return true;
      if (_queueFilter == 'Pending BOI') return item['status'].toString().contains('BOI');
      if (_queueFilter == 'Risk Alert') return item['risk'].toString().contains('Standard');
      if (_queueFilter == 'Cleared') return item['status'].toString().contains('Cleared');
      return true;
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Blue Officer Banner (100% matched to Owner and Driver Welcome Banner)
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
                              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ValueListenableBuilder<InspectorProfileModel>(
                                valueListenable: DriverApiService.currentInspectorNotifier,
                                builder: (context, inspector, _) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${settings.tr('hello')}, ${inspector.fullName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        inspector.dutyStation,
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
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                            tooltip: 'Alerts',
                            onPressed: () => setState(() => _currentIndex = 2),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.security_rounded, color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3 Metric Pills inside banner (100% matched to Owner and Driver Banner!)
                  Row(
                    children: [
                      _buildMetricPill('03', 'In Queue', Colors.white, Colors.white.withValues(alpha: 0.18)),
                      const SizedBox(width: 10),
                      _buildMetricPill('28', 'Cleared Today', Colors.white, Colors.white.withValues(alpha: 0.18)),
                      const SizedBox(width: 10),
                      _buildMetricPill('01', 'Tamper Alerts', const Color(0xFFFCA5A5), const Color(0xFFEF4444).withValues(alpha: 0.3)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inspection Queue (${filteredQueue.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Live Terminal Feed',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQueueFilterChip('All', _queueFilter == 'All', () => setState(() => _queueFilter = 'All')),
                  const SizedBox(width: 8),
                  _buildQueueFilterChip('Pending BOI', _queueFilter == 'Pending BOI', () => setState(() => _queueFilter = 'Pending BOI')),
                  const SizedBox(width: 8),
                  _buildQueueFilterChip('Risk Alert', _queueFilter == 'Risk Alert', () => setState(() => _queueFilter = 'Risk Alert')),
                  const SizedBox(width: 8),
                  _buildQueueFilterChip('Cleared', _queueFilter == 'Cleared', () => setState(() => _queueFilter = 'Cleared')),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Container Cards List (Matching Owner Container Cards with pixel-perfect cohesion)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredQueue.length,
              itemBuilder: (context, index) {
                final item = filteredQueue[index];
                final isCleared = item['status'].toString().contains('Cleared');

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                                  item['id'] as String,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item['haulier']} • ${item['vehicle']}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (item['riskColor'] as Color).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              item['risk'] as String,
                              style: TextStyle(
                                color: item['riskColor'] as Color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                              item['route'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Info Footer Badges (Matching Owner and Driver info bars)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Flexible(child: _buildInfoBadge(Icons.scale_rounded, 'Weight', item['weight'] as String, textColor)),
                            const SizedBox(width: 6),
                            Flexible(
                              flex: 2,
                              child: _buildInfoBadge(Icons.lock_rounded, 'Seal', item['seal'] as String, const Color(0xFF0284C7)),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              flex: 2,
                              child: _buildInfoBadge(
                                Icons.category_rounded,
                                'Cargo',
                                item['cargo'] as String,
                                textColor,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Bottom Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _containerCtrl.text = item['id'] as String;
                                  _sealCtrl.text = item['seal'] as String;
                                  _currentIndex = 1; // Direct jump to Smart Seal Terminal
                                });
                              },
                              icon: Icon(isCleared ? Icons.verified_rounded : Icons.qr_code_scanner_rounded, size: 16),
                              label: Text(
                                isCleared ? 'View Clearance Pass' : 'Inspect & Verify (UC-01/03)',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCleared ? const Color(0xFF16A34A) : AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Report Violation',
                            icon: const Icon(Icons.warning_amber_rounded, color: AppColors.alertRed),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.alertRedLight,
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() {
                                _containerCtrl.text = item['id'] as String;
                                _currentIndex = 2; // Direct jump to Incident logger
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// TAB 1: Step-by-Step Electronic Smart Seal Verification Terminal (SRS UC-01 & UC-03)
  Widget _buildSmartSealTab(Color cardColor, Color textColor, Color borderColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F2B48) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Electronic Smart Seal Terminal',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      Text(
                        'SRS Protocol: UC-01 (Departure Pairing) & UC-03 (Arrival Unlock)',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // STEP 1: Container & Hardware Selection
          _buildStepHeader('1', 'Target Container & Cryptographic Seal'),
          const SizedBox(height: 10),

          // Quick Container Selection Chips (Filtered for Inspector Duty Station)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _getStationFilteredQueue().map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildContainerSelectChip(item['id'], item['destination'] ?? item['id']),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          _buildField('Container Identification No', _containerCtrl, Icons.all_inbox_rounded, cardColor, textColor, borderColor),
          const SizedBox(height: 12),
          _buildField('Smart IoT Hardware ID / Seal No', _sealCtrl, Icons.lock_outline_rounded, cardColor, textColor, borderColor),
          const SizedBox(height: 12),

          // NFC / Barcode Hardware Scan Trigger
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.primaryBlue,
                  content: Row(
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '✅ NFC / QR Seal scan verified: Hardware ID ESEAL-SL-90821 linked.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: Text('Simulate NFC / QR Barcode Scan', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.skyBlue : AppColors.primaryBlue,
              side: BorderSide(color: isDark ? AppColors.skyBlue : AppColors.primaryBlue),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 24),

          // STEP 2: Customs Physical Inspection Checklist
          _buildStepHeader('2', 'Customs Physical Verification Checklist'),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChecklistTile(
                  title: 'Electronic Seal Integrity Intact',
                  subtitle: 'No physical cut, enclosure tampering, or cable bypass',
                  value: _sealIntegrityChecked,
                  onChanged: (v) => setState(() => _sealIntegrityChecked = v ?? false),
                  textColor: textColor,
                ),
                const Divider(height: 14, color: Color(0xFFE2E8F0)),
                _buildChecklistTile(
                  title: 'Weighbridge Manifest Weight Match',
                  subtitle: 'Gross weight 24,500 kg matches within ±0.2% tolerance',
                  value: _weightMatchChecked,
                  onChanged: (v) => setState(() => _weightMatchChecked = v ?? false),
                  textColor: textColor,
                ),
                const Divider(height: 14, color: Color(0xFFE2E8F0)),
                _buildChecklistTile(
                  title: 'Door Telemetry & Optical Sensors Armed',
                  subtitle: 'Magnetic door contacts actively synchronized with Cloud GPS',
                  value: _manifestMatchChecked,
                  onChanged: (v) => setState(() => _manifestMatchChecked = v ?? false),
                  textColor: textColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // STEP 3: Executive Action Terminal (Lock vs Unlock)
          _buildStepHeader('3', 'Execute Clearance Operation'),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _lockContainer,
                  icon: const Icon(Icons.lock_rounded, size: 16),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Lock & Dispatch (UC-01)', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _unlockContainer,
                  icon: const Icon(Icons.lock_open_rounded, size: 16),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Authorize & Unlock (UC-03)', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),

          if (_statusMessage != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _isSuccess ? const Color(0xFF22C55E) : const Color(0xFFEF4444)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_isSuccess ? Icons.verified_user_rounded : Icons.error_rounded,
                          color: _isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                      const SizedBox(width: 10),
                      Text(
                        _isSuccess ? 'Customs Gate Clearance Status' : 'Security Alert Triggered',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: _isSuccess ? const Color(0xFF166534) : const Color(0xFF991B1B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _isSuccess ? const Color(0xFF166534) : const Color(0xFF991B1B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// TAB 2: Customs Tamper Incident Logger & History
  Widget _buildViolationTab(Color cardColor, Color textColor, Color borderColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3B151E) : const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE11D48),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.report_problem_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customs Incident & Tamper Logger',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      Text(
                        'Customs Ordinance (Cap. 235) Violation Record Filing',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildField('Target Container No', _containerCtrl, Icons.all_inbox_rounded, cardColor, textColor, borderColor),
          const SizedBox(height: 14),

          Text('Violation Category', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedViolationType,
                dropdownColor: cardColor,
                isExpanded: true,
                items: [
                  'Tamper Sensor Triggered',
                  'Unauthorized Door Opening',
                  'Broken Physical / IoT Seal',
                  'Suspicious Route Deviation',
                  'Weight Discrepancy > 500kg',
                ].map((type) => DropdownMenuItem(value: type, child: Text(type, style: GoogleFonts.poppins(fontSize: 13, color: textColor)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedViolationType = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text('Priority Severity Level', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildSeverityChip('Advisory Notice', const Color(0xFF0284C7)),
              const SizedBox(width: 8),
              _buildSeverityChip('High Priority', const Color(0xFFD97706)),
              const SizedBox(width: 8),
              _buildSeverityChip('Immediate Impound', const Color(0xFFDC2626)),
            ],
          ),
          const SizedBox(height: 14),

          Text('Incident Notes & Officer Remarks', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _violationDescCtrl,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13, color: textColor),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
                hintText: 'Describe physical state, seal condition, truck license plate, driver details...',
                hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _submitViolationReport,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text('Dispatch Priority Alert & Log Incident', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alertRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Incident History Section
          Text(
            'Shift Incident Log History (${_recentIncidents.length})',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentIncidents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final inc = _recentIncidents[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(inc['container']!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                              Text(inc['time']!, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${inc['category']} • ${inc['severity']}', style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                          Text('Logged by: ${inc['officer']}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// TAB 3: Inspector Officer Profile Tab (100% matched to Owner and Driver Profile UX)
  Widget _buildInspectorProfileTab(Color cardColor, Color textColor, Color borderColor, bool isDark, AppSettingsController settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Officer Header Card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B3A5A) : AppColors.skyLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.4)),
                  ),
                  child: Icon(Icons.security_rounded, color: isDark ? AppColors.skyBlue : AppColors.primaryBlue, size: 34),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _officerName,
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Badge: INSP-13 • $_dutyStation',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Authorized Customs Inspector (Level 2)',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Officer & Station Details Card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Officer Credentials & Post Details',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 16),
                _buildProfileRow(Icons.badge_outlined, 'Customs Officer ID', 'INSP-13 (Enforcement Wing)', textColor),
                Divider(height: 24, color: borderColor),
                _buildProfileRow(Icons.location_on_outlined, 'Duty Station', _dutyStation, textColor),
                Divider(height: 24, color: borderColor),
                _buildProfileRow(Icons.phone_outlined, 'Control Room Intercom', _intercom, textColor),
                Divider(height: 24, color: borderColor),
                _buildProfileRow(Icons.verified_user_outlined, 'Electronic Key Authority', 'Cryptographic Clearance Level 2', textColor),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Shift Duty & Inspection Statistics
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shift Duty & Clearance Statistics',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatBox('28', 'Cleared Today', const Color(0xFF16A34A), isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7)),
                    const SizedBox(width: 12),
                    _buildStatBox('03', 'Pending Queue', const Color(0xFF0284C7), isDark ? const Color(0xFF0369A1) : const Color(0xFFE0F2FE)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatBox('4.2m', 'Avg Check Time', isDark ? Colors.white70 : const Color(0xFF475569), isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                    const SizedBox(width: 12),
                    _buildStatBox('01', 'Tamper Logged', const Color(0xFFDC2626), isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Edit Officer Credentials Card
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B3A5A) : const Color(0xFFE0EDFB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryBlue, size: 24),
              ),
              title: Text(
                'Edit Officer Credentials',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor),
              ),
              subtitle: Text(
                'Modify duty station terminal, intercom, or officer name',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
              onTap: () => _showEditInspectorDialog(context, isDark, textColor, cardColor, borderColor),
            ),
          ),

          const SizedBox(height: 24),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const DriverLoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
              label: Text(
                settings.tr('sign_out'),
                style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Helper Widgets matching Owner and Driver standard ---

  Widget _buildStepHeader(String number, String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildContainerSelectChip(String containerId, String dest) {
    final isSelected = _containerCtrl.text == containerId;
    return ChoiceChip(
      label: Text('$containerId ($dest)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _containerCtrl.text = containerId;
            final match = _allInspectionContainers.firstWhere((e) => e['id'] == containerId, orElse: () => {});
            if (match.isNotEmpty) {
              _sealCtrl.text = match['seal'] as String;
            }
          });
        }
      },
      selectedColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textDark,
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildChecklistTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Color textColor,
  }) {
    return CheckboxListTile(
      title: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primaryBlue,
    );
  }

  Widget _buildSeverityChip(String label, Color color) {
    final isSelected = _selectedSeverity == label;
    return InkWell(
      onTap: () => setState(() => _selectedSeverity = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : const Color(0xFFCBD5E1), width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildQueueFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
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

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, Color cardColor, Color textColor, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: ctrl,
            style: GoogleFonts.poppins(fontSize: 13, color: textColor),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
              Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, Color valueColor, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
