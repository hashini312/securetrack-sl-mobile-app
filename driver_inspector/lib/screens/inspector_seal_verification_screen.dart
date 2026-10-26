import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../services/driver_api_service.dart';

class InspectorSealVerificationScreen extends StatefulWidget {
  final String dutyStation;
  final String initialContainerId;
  final String initialSealId;
  final List<Map<String, dynamic>> queue;
  final VoidCallback onClearanceCompleted;

  const InspectorSealVerificationScreen({
    super.key,
    required this.dutyStation,
    this.initialContainerId = 'CONT-LK-001',
    this.initialSealId = 'IOT-DEV-001',
    required this.queue,
    required this.onClearanceCompleted,
  });

  @override
  State<InspectorSealVerificationScreen> createState() => _InspectorSealVerificationScreenState();
}

class _InspectorSealVerificationScreenState extends State<InspectorSealVerificationScreen> {
  late final TextEditingController _containerCtrl;
  late final TextEditingController _sealCtrl;

  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = true;
  bool _sealIntegrityChecked = true;
  bool _weightMatchChecked = true;
  bool _manifestMatchChecked = true;

  @override
  void initState() {
    super.initState();
    _containerCtrl = TextEditingController(text: widget.initialContainerId);
    _sealCtrl = TextEditingController(text: widget.initialSealId);
  }

  @override
  void dispose() {
    _containerCtrl.dispose();
    _sealCtrl.dispose();
    super.dispose();
  }

  void _lockContainer() async {
    setState(() => _isLoading = true);
    final containerId = _containerCtrl.text.trim();
    final sealId = _sealCtrl.text.trim();

    final success = await DriverApiService.lockContainer(containerId, sealId);
    setState(() {
      _isLoading = false;
      _isSuccess = success;
      _statusMessage = success
          ? 'Cryptographic Lock engaged for container $containerId. IoT Seal $sealId armed. Authorized for Corridor Dispatch.'
          : 'Failed to engage lock command. Please verify hardware connection.';
    });
    if (_isSuccess) {
      widget.onClearanceCompleted();
    }
  }

  void _unlockContainer() async {
    setState(() => _isLoading = true);
    final containerId = _containerCtrl.text.trim();
    final sealId = _sealCtrl.text.trim();

    final success = await DriverApiService.unlockContainer(containerId, sealId);
    setState(() {
      _isLoading = false;
      _isSuccess = success;
      _statusMessage = success
          ? 'Destination Inward Clearance verified. Smart Seal $sealId disarmed. Container $containerId cleared for Gate Pass.'
          : 'Failed to unlock seal. Sensor tamper flag still active.';
    });
    if (_isSuccess) {
      widget.onClearanceCompleted();
    }
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

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.queue.map((item) {
                final isSelected = _containerCtrl.text == item['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _containerCtrl.text = item['id'];
                        final tagMatch = RegExp(r'IOT-DEV-\d+').firstMatch(item['seal'] ?? '');
                        if (tagMatch != null) {
                          _sealCtrl.text = tagMatch.group(0)!;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.skyBlue : AppColors.primaryBlue)
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppColors.skyBlue : AppColors.primaryBlue)
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        ),
                      ),
                      child: Text(
                        '${item['id']} (${item['destination'] ?? ''})',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          _buildField('Container Identification No', _containerCtrl, Icons.all_inbox_rounded, cardColor, textColor, borderColor),
          const SizedBox(height: 12),
          _buildField('Smart IoT Hardware ID / Seal No', _sealCtrl, Icons.lock_outline_rounded, cardColor, textColor, borderColor),
          const SizedBox(height: 12),


          // STEP 2: Customs Physical Verification Checklist
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
                  subtitle: 'Gross weight matches within Â±0.2% tolerance',
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

          // STEP 3: Action Buttons
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
                      Icon(
                        _isSuccess ? Icons.verified_user_rounded : Icons.error_rounded,
                        color: _isSuccess ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
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
          alignment: Alignment.center,
          child: Text(
            number,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
      ],
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

  Widget _buildChecklistTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Color textColor,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryBlue,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
    );
  }
}
