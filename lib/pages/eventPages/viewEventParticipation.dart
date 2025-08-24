import 'package:flutter/material.dart';

import 'package:pcist/secret.dart'; // Replace with your actual path

class ViewParticipationPage extends StatelessWidget {
  final Event event;

  const ViewParticipationPage({super.key, required this.event});

  String _extractMemberName(dynamic m) {
    if (m == null) return 'Unknown';
    if (m is String) return m;
    if (m is Map) {
      final dynamic v = m['Name'] ?? m['name'] ?? m['memberName'] ?? m['fullName'] ?? m['fullname'] ?? m['email'];
      if (v == null) return 'Unknown';
      return v.toString();
    }
    return m.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${event.eventName} Participation'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: event.eventType == 'solo' ? _buildSoloList() : _buildTeamList(),
      ),
    );
  }

  // 🔸 Solo event: show list of registered member names
  Widget _buildSoloList() {
    if (event.registeredMembers.isEmpty) {
      return const Center(child: Text("No registered members yet."));
    }

    return ListView.builder(
      itemCount: event.registeredMembers.length,
      itemBuilder: (context, index) {
    final memberName = _extractMemberName(event.registeredMembers[index]);
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
      title: Text(memberName),
          ),
        );
      },
    );
  }

  // 🔹 Team event: show list of teams and expandable members
  Widget _buildTeamList() {
    if (event.registeredTeams.isEmpty) {
      return const Center(child: Text("No registered teams yet."));
    }

    return ListView.builder(
      itemCount: event.registeredTeams.length,
      itemBuilder: (context, index) {
        final team = event.registeredTeams[index];
  final String teamName = team.teamName;
        final dynamic rawMembers = team.members;
        List<String> members = const [];
        if (rawMembers is List) {
          members = rawMembers.map((m) => _extractMemberName(m)).toList();
        } else if (rawMembers is Map) {
          members = rawMembers.values.map((m) => _extractMemberName(m)).toList();
        }

        return Card(
          child: ExpansionTile(
            leading: const Icon(Icons.groups),
            title: Text(teamName),
            children: members
                .map(
                  (memberName) => ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(memberName),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
