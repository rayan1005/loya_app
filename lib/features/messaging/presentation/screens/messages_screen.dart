import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/data/models/models.dart';
import '../../../../core/data/providers/data_providers.dart';
import '../../../../core/data/services/api_service.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _selectedProgramId;
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessId = ref.watch(currentBusinessIdProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(LucideIcons.send, size: 28, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('الرسائل والإشعارات', style: AppTypography.headline),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'أرسل إشعارات Push لعملائك',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Content - responsive layout
              if (isMobile) ...[
                // Mobile: stacked layout
                _buildComposeCard(businessId),
                const SizedBox(height: 24),
                Text('سجل الرسائل', style: AppTypography.titleMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: businessId == null
                      ? const Center(child: Text('يرجى تسجيل الدخول'))
                      : _buildMessageHistory(businessId),
                ),
              ] else ...[
                // Desktop: side by side layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildComposeCard(businessId),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('سجل الرسائل', style: AppTypography.titleMedium),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 500,
                            child: businessId == null
                                ? const Center(child: Text('يرجى تسجيل الدخول'))
                                : _buildMessageHistory(businessId),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposeCard(String? businessId) {
    final programsAsync = ref.watch(programsProvider);

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
              Icon(LucideIcons.bellRing, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('رسالة جديدة', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 20),

          // Select Program
          programsAsync.when(
            data: (programs) {
              debugPrint('MessagesScreen: Loaded ${programs.length} programs');
              return DropdownButtonFormField<String?>(
                initialValue: _selectedProgramId,
                decoration: InputDecoration(
                  labelText: 'البرنامج',
                  hintText: 'جميع البرامج',
                  prefixIcon: const Icon(LucideIcons.gift),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('جميع البرامج')),
                  ...programs.map((p) =>
                      DropdownMenuItem(value: p.id, child: Text(p.name))),
                ],
                onChanged: (value) =>
                    setState(() => _selectedProgramId = value),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, stack) {
              debugPrint('MessagesScreen programs error: $error');
              return Text('خطأ في تحميل البرامج: $error');
            },
          ),
          const SizedBox(height: 16),

          // Title
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'عنوان الرسالة',
              hintText: 'مثال: عرض خاص لك!',
              prefixIcon: const Icon(LucideIcons.type),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // Body
          TextFormField(
            controller: _bodyController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'نص الرسالة',
              hintText: 'اكتب رسالتك هنا...',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(LucideIcons.messageSquare),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // Send Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : () => _sendMessage(businessId),
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(LucideIcons.send),
              label: Text(_isSending ? 'جاري الإرسال...' : 'إرسال للجميع'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageHistory(String businessId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('businessId', isEqualTo: businessId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('Messages error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.alertCircle, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تحميل الرسائل',
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.inbox,
                    size: 64, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                Text(
                  'لا توجد رسائل سابقة',
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final message = PushMessage.fromFirestore(doc);
            return _buildMessageCard(message);
          },
        );
      },
    );
  }

  Widget _buildMessageCard(PushMessage message) {
    final statusColor = switch (message.status) {
      MessageStatus.sent => AppColors.success,
      MessageStatus.sending => AppColors.warning,
      MessageStatus.failed => AppColors.error,
      _ => AppColors.textTertiary,
    };

    final statusText = switch (message.status) {
      MessageStatus.sent => 'تم الإرسال',
      MessageStatus.sending => 'جاري الإرسال',
      MessageStatus.failed => 'فشل الإرسال',
      MessageStatus.scheduled => 'مجدول',
      MessageStatus.draft => 'مسودة',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(message.title, style: AppTypography.titleMedium),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      message.status == MessageStatus.sent
                          ? LucideIcons.checkCircle
                          : LucideIcons.clock,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: AppTypography.caption.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.body,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(LucideIcons.users, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${message.sentCount} مستلم',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(width: 16),
              Icon(LucideIcons.calendar,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                _formatDate(message.createdAt),
                style: AppTypography.caption
                    .copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _sendMessage(String? businessId) async {
    if (businessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول')),
      );
      return;
    }

    if (_selectedProgramId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار البرنامج'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال الرسالة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final apiService = ApiService();

      // Call the backend to broadcast the message to all pass holders
      final result = await apiService.broadcastMessage(
        programId: _selectedProgramId!,
        message: _bodyController.text.trim(),
        title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
      );

      final message = PushMessage(
        id: '',
        businessId: businessId,
        programId: _selectedProgramId,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        sentAt: DateTime.now(),
        sentCount: result['pushed'] ?? 0,
      );

      // Save to Firestore for history
      await FirebaseFirestore.instance
          .collection('messages')
          .add(message.toFirestore());

      _titleController.clear();
      _bodyController.clear();
      setState(() => _selectedProgramId = null);

      if (mounted) {
        final pushed = result['pushed'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ تم إرسال الرسالة إلى $pushed عميل'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
