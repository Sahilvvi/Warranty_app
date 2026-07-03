import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';

const String warrantyCheckTask = 'warrantyExpiryCheck';
const String periodicWarrantyCheck = 'periodicWarrantyCheck';

// This must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case warrantyCheckTask:
      case periodicWarrantyCheck:
        final notificationService = NotificationService();
        await notificationService.initialize();
        await notificationService.checkAndScheduleNotifications();
        break;
    }
    return true;
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> registerPeriodicCheck() async {
    // Check every 12 hours for warranty expiry
    await Workmanager().registerPeriodicTask(
      periodicWarrantyCheck,
      periodicWarrantyCheck,
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> runImmediateCheck() async {
    await Workmanager().registerOneOffTask(
      warrantyCheckTask,
      warrantyCheckTask,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
