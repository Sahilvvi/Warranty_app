import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/warranty_provider.dart';
import '../../models/warranty_model.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _notificationsEnabled = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WarrantyProvider>().fetchWarranties();
    });
  }

  List<_NotificationItem> _getNotifications(List<WarrantyRegistration> warranties) {
    final notifications = <_NotificationItem>[];
    final now = DateTime.now();

    for (final warranty in warranties) {
      final daysUntilExpiry = warranty.warrantyEndDate.difference(now).inDays;

      if (daysUntilExpiry < 0) {
        notifications.add(_NotificationItem(
          icon: Icons.cancel_rounded,
          color: Colors.red,
          title: 'Warranty Expired',
          message: '${warranty.productName} (SN: ${warranty.serialNumber}) warranty expired ${-daysUntilExpiry} days ago',
          time: warranty.warrantyEndDate,
          type: 'expired',
        ));
      } else if (daysUntilExpiry <= 7) {
        notifications.add(_NotificationItem(
          icon: Icons.warning_amber_rounded,
          color: Colors.red[700]!,
          title: 'Expires in $daysUntilExpiry days!',
          message: '${warranty.productName} (SN: ${warranty.serialNumber}) - Urgent action needed',
          time: warranty.warrantyEndDate,
          type: 'critical',
        ));
      } else if (daysUntilExpiry <= 30) {
        notifications.add(_NotificationItem(
          icon: Icons.schedule_rounded,
          color: Colors.orange,
          title: 'Expiring Soon - $daysUntilExpiry days left',
          message: '${warranty.productName} (SN: ${warranty.serialNumber}) - Plan for renewal',
          time: warranty.warrantyEndDate,
          type: 'warning',
        ));
      } else if (daysUntilExpiry <= 60) {
        notifications.add(_NotificationItem(
          icon: Icons.info_outline_rounded,
          color: Colors.blue,
          title: 'Warranty reminder - $daysUntilExpiry days left',
          message: '${warranty.productName} (SN: ${warranty.serialNumber})',
          time: warranty.warrantyEndDate,
          type: 'info',
        ));
      }
    }

    // Sort by urgency (most urgent first)
    notifications.sort((a, b) {
      final order = {'critical': 0, 'expired': 1, 'warning': 2, 'info': 3};
      return (order[a.type] ?? 4).compareTo(order[b.type] ?? 4);
    });

    return notifications;
  }

  Future<void> _refreshNotifications() async {
    setState(() => _isChecking = true);
    await NotificationService().checkAndScheduleNotifications();
    if (mounted) {
      await context.read<WarrantyProvider>().fetchWarranties();
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications refreshed!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: _isChecking
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isChecking ? null : _refreshNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Notification Settings Card
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3F51B5).withOpacity(0.08),
                  const Color(0xFF3F51B5).withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF3F51B5).withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F51B5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_active, color: Color(0xFF3F51B5), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expiry Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('Get notified before warranty expires',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() => _notificationsEnabled = value);
                    if (value) {
                      await NotificationService().checkAndScheduleNotifications();
                    } else {
                      await NotificationService().cancelAll();
                    }
                  },
                  activeColor: const Color(0xFF3F51B5),
                ),
              ],
            ),
          ),

          // Alert Timeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Alert Timeline',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('30 days • 7 days • 1 day', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notification List
          Expanded(
            child: Consumer<WarrantyProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications = _getNotifications(provider.warranties);

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'All Clear!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No warranty expiry alerts at this time',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _NotificationCard(notification: notification);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final DateTime time;
  final String type;

  _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: notification.type == 'critical' ? 3 : 1,
        shadowColor: notification.color.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: notification.color, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: notification.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(notification.icon, color: notification.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: notification.type == 'critical' ? notification.color : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Expires: ${DateFormat('dd MMM yyyy').format(notification.time)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
