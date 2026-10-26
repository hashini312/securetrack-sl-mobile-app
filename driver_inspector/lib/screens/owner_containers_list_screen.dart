import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/app_settings.dart';
import 'owner_container_details_screen.dart';

class OwnerContainersListScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const OwnerContainersListScreen({super.key, this.onBackToHome});

  @override
  State<OwnerContainersListScreen> createState() => _OwnerContainersListScreenState();
}

class _OwnerContainersListScreenState extends State<OwnerContainersListScreen> {
  List<ContainerItem> _containers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    ApiService.currentOwnerNotifier.addListener(_onOwnerChanged);
    _loadData();
  }

  @override
  void dispose() {
    ApiService.currentOwnerNotifier.removeListener(_onOwnerChanged);
    super.dispose();
  }

  void _onOwnerChanged() {
    _loadData();
  }

  void _loadData() async {
    final list = await ApiService.getOwnerContainers();
    if (mounted) {
      setState(() {
        _containers = list;
        _loading = false;
      });
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
        final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFEDF2F7);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: const Text('Registered Containers'),
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
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
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _containers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _containers[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OwnerContainerDetailsScreen(container: item),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F2B48) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryBlue, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.containerNo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                                  ),
                                  const SizedBox(height: 3),
                                  Text('${item.type} • ${item.weight}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  const SizedBox(height: 4),
                                  Text('Dest: ${item.destination}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: item.status == 'Active' ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: item.status == 'Active' ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
