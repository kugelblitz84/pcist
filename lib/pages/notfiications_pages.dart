import 'package:flutter/material.dart';
import 'package:pcist/config/firebase.dart'; // Adjust path
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, String>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _markAllRead();
    _loadNotifications();
  }

  Future<void> _markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hasUnread", false);
  }

  Future<void> _loadNotifications() async {
    var data = await FirebaseNotifications.getNotifications();
    setState(() {
      _notifications = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text("No notifications yet."))
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        notif["title"] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notif["body"] ?? ""),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(notif["time"]),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      leading: const Icon(Icons.notifications),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return "";
    DateTime dateTime = DateTime.tryParse(isoTime) ?? DateTime.now();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
