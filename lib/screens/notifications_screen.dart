import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/providers/auth_provider.dart';
import 'package:job_seeker/providers/notification_provider.dart';
import 'package:job_seeker/models/notification_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).userId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please log in to view notifications')),
      );
    }

    final notificationsAsync = ref.watch(notificationsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(notificationsProvider(userId));
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider(userId));
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationTile(notification: notification);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(notificationsProvider(userId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isApplicationStatus = notification.type == 'APPLICATION_STATUS';

    Color getStatusColor(String? status) {
      if (status == null) return Colors.grey;
      final s = status.toLowerCase();
      if (s.contains('accepted')) return Colors.green;
      if (s.contains('rejected')) return Colors.red;
      if (s.contains('interview')) return Colors.blue;
      return Colors.grey;
    }

    IconData getIcon() {
      if (!isApplicationStatus) return Icons.notifications;
      final status = notification.status?.toLowerCase() ?? '';
      if (status.contains('accepted')) return Icons.check_circle;
      if (status.contains('rejected')) return Icons.cancel;
      if (status.contains('interview')) return Icons.event;
      return Icons.info;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isApplicationStatus
            ? getStatusColor(notification.status).withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.2),
        child: Icon(
          getIcon(),
          color: isApplicationStatus
              ? getStatusColor(notification.status)
              : Colors.grey,
        ),
      ),
      title: Text(
        notification.message,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(notification.timestamp),
      trailing: notification.isRead
          ? null
          : Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
      onTap: () {
        // TODO: Navigate to application detail if it's an application status notification
        // if (isApplicationStatus && notification.applicationId != null) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => ApplicationDetailScreen(
        //         applicationId: int.parse(notification.applicationId!),
        //       ),
        //     ),
        //   );
        // }
      },
    );
  }
}
