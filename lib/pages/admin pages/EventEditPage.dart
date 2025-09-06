import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:pcist/services/eventApi.dart';
import 'package:pcist/config/eventsConfig.dart';
import 'package:pcist/secret.dart';

class EventEditPage extends StatefulWidget {
  final Event event;
  const EventEditPage({super.key, required this.event});

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  late TextEditingController _name;
  late TextEditingController _description;
  late TextEditingController _location;
  DateTime? _date;
  DateTime? _deadline;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.event.eventName ?? '');
    _description = TextEditingController(text: widget.event.description ?? '');
    _location = TextEditingController(text: widget.event.location ?? '');
    _date = widget.event.date;
    _deadline = widget.event.registrationDeadline;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final res = await EventApi.updateEvent(
        id: widget.event.id ?? '',
        eventName: _name.text.trim().isEmpty ? null : _name.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        date: _date != null ? DateFormat('yyyy-MM-dd').format(_date!) : null,
        registrationDeadline: _deadline != null
            ? DateFormat('yyyy-MM-dd').format(_deadline!)
            : null,
      );
      if (res != null && res.statusCode == 200) {
        Get.snackbar('Success', 'Event updated');
        await Eventsconfig.initializeEvents();
        Get.back();
      } else {
        Get.snackbar('Error', 'Update failed');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Event Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Event Date'),
                    subtitle: Text(
                      _date != null
                          ? DateFormat('dd MMM yyyy').format(_date!)
                          : 'Not set',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: _pickDate,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Registration Deadline'),
                    subtitle: Text(
                      _deadline != null
                          ? DateFormat('dd MMM yyyy').format(_deadline!)
                          : 'Not set',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.event_available),
                      onPressed: _pickDeadline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
