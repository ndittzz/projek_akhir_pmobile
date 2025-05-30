import 'package:flutter/material.dart';

class NotificationManager extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _hasUnreadNotifications = false;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get hasUnreadNotifications => _hasUnreadNotifications;

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void clearNotifications() {
    _hasUnreadNotifications = false;
    notifyListeners();
  }

  void newNotification() {
    if (_notificationsEnabled) {
      _hasUnreadNotifications = true;
      notifyListeners();
    }
  }
}
