import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/config/eventsConfig.dart';
import 'package:pcist/services/eventApi.dart';
import 'package:pcist/secret.dart';

class EventPaymentsPage extends StatefulWidget {
  final String? eventId; // minimal identifier passed from ManageEventsPage
  const EventPaymentsPage({super.key, this.eventId});

  @override
  State<EventPaymentsPage> createState() => _EventPaymentsPageState();
}

class _EventPaymentsPageState extends State<EventPaymentsPage> {
  Event? _selectedEvent;
  bool _loading = false;
  final Map<String, bool> _soloSelection = {}; // userId/classroll keyed
  final Map<String, bool> _teamSelection = {}; // teamName keyed
  final Map<String, String> _soloLabels = {}; // key -> display name

  @override
  void initState() {
    super.initState();
    if (!Eventsconfig.eventsLoaded.value) {
      Eventsconfig.initializeEvents().then((_) => _initFromId());
    } else {
      _initFromId();
    }
  }

  void _initFromId() {
    if (widget.eventId == null) return; // no preselected id
    final ev = Eventsconfig.allEvents.firstWhereOrNull(
      (e) => e.id == widget.eventId,
    );
    if (ev != null) {
      _chooseEvent(ev);
    }
  }

  void _chooseEvent(Event event) {
    setState(() {
      _selectedEvent = event;
      _soloSelection.clear();
      _teamSelection.clear();
      if (event.eventType == 'solo') {
        for (final m in event.registeredMembers) {
          final key = m.userId?.isNotEmpty == true
              ? 'id:${m.userId}'
              : 'cr:${m.classroll}';
          _soloSelection[key] = m.paymentStatus ?? false;
          // Prefer real name; fallback to identifier
          final fallback = key.startsWith('id:')
              ? key.substring(3)
              : key.substring(3);
          _soloLabels[key] = (m.name != null && m.name!.trim().isNotEmpty)
              ? m.name!
              : fallback;
        }
      } else {
        for (final t in event.registeredTeams) {
          // team considered paid only if all members paid
          final paidAll =
              t.members.isNotEmpty &&
              t.members.every((m) => m.paymentStatus == true);
          _teamSelection[t.teamName] = paidAll;
        }
      }
    });
  }

  Future<void> _submitSoloUpdates() async {
    if (_selectedEvent == null) return;
    setState(() => _loading = true);
    try {
      final membersPayload = _soloSelection.entries.map((e) {
        final key = e.key;
        final status = e.value;
        if (key.startsWith('id:')) {
          return {'userId': key.substring(3), 'status': status};
        } else {
          return {
            'classroll': int.tryParse(key.substring(3)) ?? 0,
            'status': status,
          };
        }
      }).toList();
      final res = await EventApi.updatePaymentStatus(
        eventId: _selectedEvent!.id ?? '',
        members: membersPayload,
      );
      if (res != null && res.statusCode == 200) {
        Get.snackbar('Success', 'Payment status updated');
        await Eventsconfig.initializeEvents();
        // refresh local
        final updated = Eventsconfig.allEvents.firstWhereOrNull(
          (e) => e.id == _selectedEvent!.id,
        );
        if (updated != null) _chooseEvent(updated);
      } else {
        Get.snackbar('Error', 'Failed (${res?.statusCode})');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitTeamUpdates() async {
    if (_selectedEvent == null) return;
    setState(() => _loading = true);
    try {
      final event = _selectedEvent!;
      int success = 0;
      int failed = 0;

      for (final team in event.registeredTeams) {
        final teamStatus = _teamSelection[team.teamName] ?? false;
        final membersPayload = <dynamic>[];
        for (final m in team.members) {
          if (m.userId != null && m.userId!.isNotEmpty) {
            membersPayload.add({'userId': m.userId, 'status': teamStatus});
          } else if (m.classroll != null) {
            membersPayload.add({
              'classroll': m.classroll,
              'status': teamStatus,
            });
          }
        }

        if (membersPayload.isEmpty) continue; // skip empty teams
        final res = await EventApi.updatePaymentStatus(
          eventId: event.id ?? '',
          members: membersPayload,
        );
        if (res != null && res.statusCode == 200) {
          success++;
        } else {
          failed++;
        }
      }

      await Eventsconfig.initializeEvents();
      final updated = Eventsconfig.allEvents.firstWhereOrNull(
        (e) => e.id == event.id,
      );
      if (updated != null) _chooseEvent(updated);

      if (failed == 0) {
        Get.snackbar('Success', 'Updated $success team(s)');
      } else if (success == 0) {
        Get.snackbar('Error', 'All team updates failed');
      } else {
        Get.snackbar('Partial', 'Success: $success  Failed: $failed');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Payments'),
        backgroundColor: Colors.deepOrange,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_selectedEvent == null)
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.eventId == null
                              ? 'Select an event from Manage Events'
                              : 'Event not found',
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: _selectedEvent!.eventType == 'solo'
                          ? _buildSoloList()
                          : _buildTeamList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _selectedEvent!.eventType == 'solo'
                            ? _submitSoloUpdates
                            : _submitTeamUpdates,
                        icon: const Icon(Icons.save),
                        label: const Text('Apply Updates'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSoloList() {
    final entries = _soloSelection.entries.toList();
    if (entries.isEmpty) {
      return const Center(child: Text('No participants'));
    }
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final key = entry.key;
        final paid = entry.value;
        final display =
            _soloLabels[key] ??
            (key.startsWith('id:') ? key.substring(3) : key.substring(3));
        return SwitchListTile(
          title: Text(display),
          value: paid,
          onChanged: (val) {
            setState(() => _soloSelection[key] = val);
          },
          secondary: Icon(
            paid ? Icons.payment : Icons.payment_outlined,
            color: paid ? Colors.green : Colors.orange,
          ),
        );
      },
    );
  }

  Widget _buildTeamList() {
    final entries = _teamSelection.entries.toList();
    if (entries.isEmpty) {
      return const Center(child: Text('No teams'));
    }
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final teamName = entry.key;
        final paid = entry.value;
        return SwitchListTile(
          title: Text(teamName),
          value: paid,
          onChanged: (val) {
            setState(() => _teamSelection[teamName] = val);
          },
          secondary: Icon(
            paid ? Icons.payment : Icons.payment_outlined,
            color: paid ? Colors.green : Colors.orange,
          ),
        );
      },
    );
  }
}
