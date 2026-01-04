import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/data/providers/data_providers.dart';

class AdvancedAnalyticsScreen extends ConsumerStatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  ConsumerState<AdvancedAnalyticsScreen> createState() =>
      _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState
    extends ConsumerState<AdvancedAnalyticsScreen> {
  String _period = '7days';
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(LucideIcons.barChart3,
                          size: 28, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text('التحليلات المتقدمة', style: AppTypography.headline),
                      const Spacer(),
                      _buildPeriodSelector(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary Cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Charts Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildStampsChart()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildTopCustomers()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // More Charts
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildCustomerGrowthChart()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildProgramsPerformance()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Retention & Engagement
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildRetentionCard()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildEngagementCard()),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodButton('7 أيام', '7days'),
          _buildPeriodButton('30 يوم', '30days'),
          _buildPeriodButton('3 أشهر', '90days'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _period == value;
    return InkWell(
      onTap: () {
        setState(() => _period = value);
        _loadAnalytics();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _buildSummaryCard(
          'العملاء الجدد',
          '${_analytics['newCustomers'] ?? 0}',
          _analytics['customerGrowth']?.toStringAsFixed(1) ?? '0',
          LucideIcons.userPlus,
          Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          'الأختام',
          '${_analytics['totalStamps'] ?? 0}',
          _analytics['stampsGrowth']?.toStringAsFixed(1) ?? '0',
          LucideIcons.stamp,
          Colors.green,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          'المكافآت',
          '${_analytics['totalRewards'] ?? 0}',
          _analytics['rewardsGrowth']?.toStringAsFixed(1) ?? '0',
          LucideIcons.gift,
          Colors.orange,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          'معدل الاحتفاظ',
          '${(_analytics['retentionRate'] ?? 0).toStringAsFixed(0)}%',
          null,
          LucideIcons.heartHandshake,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, String? growth, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (growth != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: double.parse(growth) >= 0
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          double.parse(growth) >= 0
                              ? LucideIcons.trendingUp
                              : LucideIcons.trendingDown,
                          size: 12,
                          color: double.parse(growth) >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$growth%',
                          style: AppTypography.caption.copyWith(
                            color: double.parse(growth) >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value,
                style: AppTypography.headline
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildStampsChart() {
    final stampsByDay = _analytics['stampsByDay'] as Map<String, int>? ?? {};

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.activity, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('الأختام حسب اليوم', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: stampsByDay.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد بيانات كافية',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.divider,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: AppTypography.caption,
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= stampsByDay.length) {
                                return const SizedBox();
                              }
                              final date =
                                  stampsByDay.keys.elementAt(value.toInt());
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  date.substring(5),
                                  style: AppTypography.caption,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: stampsByDay.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            return FlSpot(entry.key.toDouble(),
                                entry.value.value.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers() {
    final topCustomers = _analytics['topCustomers'] as List? ?? [];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.crown, color: Colors.amber),
              const SizedBox(width: 8),
              Text('أفضل العملاء', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          if (topCustomers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'لا توجد بيانات',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textTertiary),
                ),
              ),
            )
          else
            ...topCustomers
                .take(5)
                .map((customer) => _buildTopCustomerItem(customer)),
        ],
      ),
    );
  }

  Widget _buildTopCustomerItem(Map<String, dynamic> customer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                (customer['name'] as String? ?? '?')[0].toUpperCase(),
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer['name'] ?? customer['phone'] ?? 'عميل',
                  style: AppTypography.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${customer['stamps'] ?? 0} ختم',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${customer['rewards'] ?? 0} مكافأة',
              style: AppTypography.caption.copyWith(color: Colors.amber[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerGrowthChart() {
    final customersByDay =
        _analytics['customersByDay'] as Map<String, int>? ?? {};

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.users, color: Colors.blue),
              const SizedBox(width: 8),
              Text('نمو العملاء', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: customersByDay.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد بيانات كافية',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.divider,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: AppTypography.caption,
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= customersByDay.length) {
                                return const SizedBox();
                              }
                              final date =
                                  customersByDay.keys.elementAt(value.toInt());
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  date.substring(8),
                                  style: AppTypography.caption,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: customersByDay.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.value.toDouble(),
                              color: Colors.blue,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramsPerformance() {
    final programs = _analytics['programsPerformance'] as List? ?? [];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.gift, color: Colors.purple),
              const SizedBox(width: 8),
              Text('أداء البرامج', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          if (programs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('لا توجد بيانات')),
            )
          else
            ...programs.map((program) => _buildProgramItem(program)),
        ],
      ),
    );
  }

  Widget _buildProgramItem(Map<String, dynamic> program) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  program['name'] ?? 'برنامج',
                  style: AppTypography.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${program['customers'] ?? 0} عميل',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ((program['stamps'] ?? 0) / 100).clamp(0.0, 1.0),
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation(
              Color(int.parse(
                  '0xFF${(program['color'] as String?)?.replaceAll('#', '') ?? '007AFF'}')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionCard() {
    final retention = _analytics['retentionRate'] ?? 0.0;

    return Container(
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
          Row(
            children: [
              Icon(LucideIcons.heartHandshake, color: Colors.pink),
              const SizedBox(width: 8),
              Text('معدل الاحتفاظ', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            width: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: retention / 100,
                    strokeWidth: 12,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation(
                      retention >= 70
                          ? Colors.green
                          : retention >= 40
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${retention.toStringAsFixed(0)}%',
                      style: AppTypography.displaySmall
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'احتفاظ',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            retention >= 70
                ? 'ممتاز! عملاؤك مخلصون'
                : retention >= 40
                    ? 'جيد، يمكن التحسين'
                    : 'يحتاج تحسين',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementCard() {
    final avgStamps = _analytics['avgStampsPerCustomer'] ?? 0.0;
    final avgVisits = _analytics['avgVisitsPerCustomer'] ?? 0.0;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, color: Colors.amber),
              const SizedBox(width: 8),
              Text('التفاعل', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 24),
          _buildEngagementStat('متوسط الأختام لكل عميل',
              avgStamps.toStringAsFixed(1), LucideIcons.stamp, Colors.green),
          const SizedBox(height: 16),
          _buildEngagementStat(
              'متوسط الزيارات لكل عميل',
              avgVisits.toStringAsFixed(1),
              LucideIcons.footprints,
              Colors.blue),
          const SizedBox(height: 16),
          _buildEngagementStat(
              'معدل إكمال البطاقات',
              '${((_analytics['completionRate'] ?? 0) * 100).toStringAsFixed(0)}%',
              LucideIcons.checkCircle,
              Colors.purple),
        ],
      ),
    );
  }

  Widget _buildEngagementStat(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
        ),
        Text(value,
            style: AppTypography.titleMedium
                .copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    final businessId = ref.read(currentBusinessIdProvider);
    if (businessId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final db = FirebaseFirestore.instance;
      final now = DateTime.now();
      final days = switch (_period) {
        '7days' => 7,
        '30days' => 30,
        '90days' => 90,
        _ => 7,
      };
      final startDate = now.subtract(Duration(days: days));

      // Get activity logs
      final activitySnapshot = await db
          .collection('activity_log')
          .where('businessId', isEqualTo: businessId)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(startDate))
          .get();

      // Get customers
      final customersSnapshot = await db
          .collection('customers')
          .where('businessId', isEqualTo: businessId)
          .get();

      // Get programs
      final programsSnapshot = await db
          .collection('programs')
          .where('businessId', isEqualTo: businessId)
          .get();

      // Calculate analytics
      int totalStamps = 0;
      int totalRewards = 0;
      int newCustomers = 0;
      Map<String, int> stampsByDay = {};
      Map<String, int> customersByDay = {};

      for (final doc in activitySnapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String?;
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final dateKey =
            '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';

        if (type == 'stamp') {
          totalStamps += (data['stampCount'] as int?) ?? 1;
          stampsByDay[dateKey] =
              (stampsByDay[dateKey] ?? 0) + ((data['stampCount'] as int?) ?? 1);
        } else if (type == 'reward') {
          totalRewards++;
        } else if (type == 'newCustomer') {
          newCustomers++;
          customersByDay[dateKey] = (customersByDay[dateKey] ?? 0) + 1;
        }
      }

      // Top customers
      final topCustomers = customersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'],
          'phone': data['phone'],
          'stamps': data['totalStamps'] ?? 0,
          'rewards': data['totalRewards'] ?? 0,
        };
      }).toList()
        ..sort((a, b) => (b['stamps'] as int).compareTo(a['stamps'] as int));

      // Programs performance
      final programsPerformance = programsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'],
          'customers': data['totalCustomers'] ?? 0,
          'stamps': data['totalStamps'] ?? 0,
          'color': data['backgroundColor'] ?? '#007AFF',
        };
      }).toList();

      // Retention rate (customers with more than 1 visit / total customers)
      final returningCustomers = customersSnapshot.docs.where((doc) {
        final visits = (doc.data()['totalVisits'] as int?) ?? 0;
        return visits > 1;
      }).length;
      final retentionRate = customersSnapshot.docs.isEmpty
          ? 0.0
          : (returningCustomers / customersSnapshot.docs.length) * 100;

      // Avg stamps per customer
      final totalCustomerStamps =
          customersSnapshot.docs.fold<int>(0, (sum, doc) {
        return sum + ((doc.data()['totalStamps'] as int?) ?? 0);
      });
      final avgStampsPerCustomer = customersSnapshot.docs.isEmpty
          ? 0.0
          : totalCustomerStamps / customersSnapshot.docs.length;

      setState(() {
        _analytics = {
          'totalStamps': totalStamps,
          'totalRewards': totalRewards,
          'newCustomers': newCustomers,
          'stampsGrowth': 12.5, // Mock
          'customerGrowth': 8.3, // Mock
          'rewardsGrowth': 15.2, // Mock
          'retentionRate': retentionRate,
          'avgStampsPerCustomer': avgStampsPerCustomer,
          'avgVisitsPerCustomer': 2.5, // Mock
          'completionRate': 0.35, // Mock
          'stampsByDay': stampsByDay,
          'customersByDay': customersByDay,
          'topCustomers': topCustomers,
          'programsPerformance': programsPerformance,
        };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      setState(() => _isLoading = false);
    }
  }
}
