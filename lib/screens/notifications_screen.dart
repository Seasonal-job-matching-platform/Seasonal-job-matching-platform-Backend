import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/providers/auth_provider.dart';
import 'package:job_seeker/providers/notification_provider.dart';
import 'package:job_seeker/models/notification_model.dart';
import 'package:job_seeker/screens/applications_screen.dart';
import 'package:job_seeker/theme/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userId = ref.watch(authProvider).userId;

    if (userId == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(l10n, null),
        body: Center(
          child: Text(
            l10n.pleaseLogInToView,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final notificationsAsync = ref.watch(notificationsProvider(userId));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(l10n, () => ref.invalidate(notificationsProvider(userId))),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _EmptyState(l10n: l10n);
          }
          return RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              ref.invalidate(notificationsProvider(userId));
            },
            color: AppTheme.primary,
            backgroundColor: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(
                  notification: notification,
                  userId: userId,
                );
              },
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('${l10n.error}: $error', style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(notificationsProvider(userId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n, VoidCallback? onRefresh) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        l10n.notifications,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noNotificationsYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll let you know when there's an update.",
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final NotificationModel notification;
  final int userId;

  const _NotificationCard({
    required this.notification,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isApplicationStatus = notification.type == 'APPLICATION_STATUS';
    final isRead = notification.isRead;

    Color getStatusColor(String? status) {
      if (status == null) return const Color(0xFF6366F1);
      final s = status.toLowerCase();
      if (s.contains('accepted') || s.contains('approved')) return const Color(0xFF10B981);
      if (s.contains('rejected') || s.contains('declined')) return const Color(0xFFEF4444);
      if (s.contains('interview')) return const Color(0xFF3B82F6);
      return const Color(0xFF6366F1);
    }

    IconData getIcon() {
      if (!isApplicationStatus) return Icons.notifications_active_rounded;
      final status = notification.status?.toLowerCase() ?? '';
      if (status.contains('accepted') || status.contains('approved')) return Icons.check_circle_rounded;
      if (status.contains('rejected') || status.contains('declined')) return Icons.cancel_rounded;
      if (status.contains('interview')) return Icons.event_rounded;
      return Icons.info_rounded;
    }

    final accentColor = isApplicationStatus ? getStatusColor(notification.status) : AppTheme.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (!isRead && notification.id != null) {
          ref.read(notificationsProvider(userId).notifier).markAsRead(notification.id!);
        }

        if (isApplicationStatus) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApplicationsScreen()),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : accentColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? Colors.grey.shade200 : accentColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isRead
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRead ? Colors.grey.shade50 : accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getIcon(),
                color: isRead ? Colors.grey.shade400 : accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.jobTitle ?? (isApplicationStatus ? 'Application Update' : 'New Notification'),
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                            fontSize: 16,
                            color: isRead ? Colors.grey.shade800 : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message ?? 'No details provided.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isRead ? Colors.grey.shade600 : Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatRelativeTime(notification.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
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

  String _formatRelativeTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'Just now';
    
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp; // Fallback to raw string if parsing fails
    }
  }
}

