import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';

class InspectorViolationsScreen extends StatefulWidget {
  final String officerName;
  final String containerId;

  const InspectorViolationsScreen({
    super.key,
    required this.officerName,
    this.containerId = 'CONT-LK-001',
  });

  @override
  State<InspectorViolationsScreen> createState() => _InspectorViolationsScreenState();
}

class _InspectorViolationsScreenState extends State<InspectorViolationsScreen> {
  late final TextEditingController _containerCtrl;
  final TextEditingController _violationDescCtrl = TextEditingController();

  String _selectedViolationType = 'Tamper Sensor Triggered';
  String _selectedSeverity = 'High Priority';

  final List<Map<String, String>> _recentIncidents = [
    {
      'container': 'CGO-1002',
      'category': 'Suspicious Route Deviation',
      'severity': 'High Priority',
      'time': '12 mins ago',
      'officer': 'Hasitha Dana (INSP-13)',
    },
    {
      'container': 'CONT-LK-009',
      'category': 'Tamper Sensor Triggered',
      'severity': 'Immediate Impound',
      'time': '1 hour ago',
      'officer': 'Samantha Perera (INSP-04)',
    },
    {
      'container': 'CGO-1005',
      'category': 'Weight Discrepancy > 500kg',
      'severity': 'Advisory Notice',
      'time': '3 hours ago',
      'officer': 'Nuwan Wickrama (INSP-08)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _containerCtrl = TextEditingController(text: widget.containerId);
  }

  @override
  void dispose() {
    _containerCtrl.dispose();
    _violationDescCtrl.dispose();
    super.dispose();
  }

  void _submitViolationReport() {
    if (_violationDescCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the incident details before filing.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final containerNo = _containerCtrl.text.trim().isEmpty ? 'CGO-1002' : _containerCtrl.text.trim();
    setState(() {
      _recentIncidents.insert(0, {
        'container': containerNo,
        'category': _selectedViolationType,
        'severity': _selectedSeverity,
        'time': 'Just now',
        'officer': widget.officerName,
      });
      _violationDescCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '🚨 Priority Alert Filed: $containerNo flagged with $_selectedViolationType.',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;
    final isDark = settings.isDarkMode;
    final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.borderLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSeverityChip('Advisory Notice', const Color(0xFF0284C7)),
                const SizedBox(width: 8),
                _buildSeverityChip('High Priority', const Color(0xFFD97706)),
                const SizedBox(width: 8),
                _buildSeverityChip('Immediate Impound', const Color(0xFFDC2626)),
              ],
            ),
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

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon,
    Color cardColor,
    Color textColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: GoogleFonts.poppins(fontSize: 13, color: textColor),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.primaryBlue),
            filled: true,
            fillColor: cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityChip(String label, Color color) {
    final isSelected = _selectedSeverity == label;
    return InkWell(
      onTap: () => setState(() => _selectedSeverity = label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
