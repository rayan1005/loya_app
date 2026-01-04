import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/data/providers/data_providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _isExporting = false;
  String _exportType = 'customers';

  @override
  Widget build(BuildContext context) {
    final businessId = ref.watch(currentBusinessIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(LucideIcons.download, size: 28, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('تصدير البيانات', style: AppTypography.headline),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'صدّر بيانات العملاء والمعاملات بصيغة CSV',
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Export Options
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Export Types
                  Expanded(
                    child: Column(
                      children: [
                        _buildExportOption(
                          icon: LucideIcons.users,
                          title: 'العملاء',
                          description:
                              'جميع بيانات العملاء: الاسم، الهاتف، الزيارات، المكافآت',
                          type: 'customers',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        _buildExportOption(
                          icon: LucideIcons.stamp,
                          title: 'الأختام والتقدم',
                          description: 'تقدم كل عميل في كل برنامج',
                          type: 'progress',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildExportOption(
                          icon: LucideIcons.activity,
                          title: 'سجل النشاط',
                          description: 'جميع الأختام والمكافآت المستبدلة',
                          type: 'activity',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        _buildExportOption(
                          icon: LucideIcons.gift,
                          title: 'البرامج',
                          description: 'إحصائيات كل برنامج ولاء',
                          type: 'programs',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),

                  // Export Preview & Button
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.fileSpreadsheet,
                            size: 64,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _getExportTitle(),
                            style: AppTypography.title,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ملف CSV يحتوي على جميع البيانات',
                            style: AppTypography.body
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 32),

                          // Export Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isExporting
                                  ? null
                                  : () => _exportData(businessId),
                              icon: _isExporting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(LucideIcons.download),
                              label: Text(_isExporting
                                  ? 'جاري التصدير...'
                                  : 'تحميل CSV'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Format Info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(LucideIcons.info,
                                    size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'يمكنك فتح الملف في Excel أو Google Sheets',
                                    style: AppTypography.caption
                                        .copyWith(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String description,
    required String type,
    required Color color,
  }) {
    final isSelected = _exportType == type;

    return InkWell(
      onTap: () => setState(() => _exportType = type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: type,
              groupValue: _exportType,
              onChanged: (value) => setState(() => _exportType = value!),
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  String _getExportTitle() {
    return switch (_exportType) {
      'customers' => 'تصدير العملاء',
      'progress' => 'تصدير التقدم',
      'activity' => 'تصدير النشاط',
      'programs' => 'تصدير البرامج',
      _ => 'تصدير',
    };
  }

  Future<void> _exportData(String? businessId) async {
    if (businessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('يرجى تسجيل الدخول'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      String csvContent;
      String fileName;

      switch (_exportType) {
        case 'customers':
          csvContent = await _exportCustomers(businessId);
          fileName = 'customers_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'progress':
          csvContent = await _exportProgress(businessId);
          fileName = 'progress_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'activity':
          csvContent = await _exportActivity(businessId);
          fileName = 'activity_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'programs':
          csvContent = await _exportPrograms(businessId);
          fileName = 'programs_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        default:
          throw Exception('نوع غير معروف');
      }

      // Download file (Web)
      _downloadCsv(csvContent, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ تم تصدير البيانات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<String> _exportCustomers(String businessId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('customers')
        .where('businessId', isEqualTo: businessId)
        .get();

    final rows = <List<String>>[];
    rows.add([
      'ID',
      'الاسم',
      'الهاتف',
      'الزيارات',
      'المكافآت',
      'آخر زيارة',
      'تاريخ التسجيل'
    ]);

    for (final doc in snapshot.docs) {
      final data = doc.data();
      rows.add([
        doc.id,
        data['name'] ?? '',
        data['phone'] ?? '',
        '${data['totalVisits'] ?? 0}',
        '${data['totalRewards'] ?? 0}',
        _formatDateForCsv(data['lastVisit']),
        _formatDateForCsv(data['createdAt']),
      ]);
    }

    return _convertToCsv(rows);
  }

  Future<String> _exportProgress(String businessId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('customer_progress')
        .where('businessId', isEqualTo: businessId)
        .get();

    final rows = <List<String>>[];
    rows.add([
      'معرف العميل',
      'معرف البرنامج',
      'الأختام',
      'المكافآت المستبدلة',
      'آخر ختم',
      'تاريخ الإنشاء'
    ]);

    for (final doc in snapshot.docs) {
      final data = doc.data();
      rows.add([
        data['customerId'] ?? '',
        data['programId'] ?? '',
        '${data['stamps'] ?? 0}',
        '${data['rewardsRedeemed'] ?? 0}',
        _formatDateForCsv(data['lastStampAt']),
        _formatDateForCsv(data['createdAt']),
      ]);
    }

    return _convertToCsv(rows);
  }

  Future<String> _exportActivity(String businessId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('activity_log')
        .where('businessId', isEqualTo: businessId)
        .orderBy('timestamp', descending: true)
        .limit(1000)
        .get();

    final rows = <List<String>>[];
    rows.add(
        ['التاريخ', 'النوع', 'العميل', 'الهاتف', 'البرنامج', 'عدد الأختام']);

    for (final doc in snapshot.docs) {
      final data = doc.data();
      rows.add([
        _formatDateForCsv(data['timestamp']),
        data['type'] ?? '',
        data['customerName'] ?? '',
        data['customerPhone'] ?? '',
        data['programName'] ?? '',
        '${data['stampCount'] ?? 1}',
      ]);
    }

    return _convertToCsv(rows);
  }

  Future<String> _exportPrograms(String businessId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('programs')
        .where('businessId', isEqualTo: businessId)
        .get();

    final rows = <List<String>>[];
    rows.add([
      'ID',
      'الاسم',
      'الوصف',
      'الأختام المطلوبة',
      'المكافأة',
      'العملاء',
      'إجمالي الأختام',
      'المكافآت',
      'الحالة'
    ]);

    for (final doc in snapshot.docs) {
      final data = doc.data();
      rows.add([
        doc.id,
        data['name'] ?? '',
        data['description'] ?? '',
        '${data['stampsRequired'] ?? 10}',
        data['rewardDescription'] ?? '',
        '${data['totalCustomers'] ?? 0}',
        '${data['totalStamps'] ?? 0}',
        '${data['totalRewards'] ?? 0}',
        (data['isActive'] ?? true) ? 'نشط' : 'غير نشط',
      ]);
    }

    return _convertToCsv(rows);
  }

  String _formatDateForCsv(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = (timestamp as Timestamp).toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _convertToCsv(List<List<String>> rows) {
    // Add UTF-8 BOM for Arabic support in Excel
    const bom = '\uFEFF';
    return bom +
        rows
            .map((row) =>
                row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(','))
            .join('\n');
  }

  void _downloadCsv(String content, String fileName) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = fileName;

    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
