import 'package:flutter/material.dart';

import 'package:pcist/secret.dart'; // Replace with your actual path

class ViewParticipationPage extends StatelessWidget {
  final Event event;

  const ViewParticipationPage({super.key, required this.event});

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
        final member = event.registeredMembers[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(member),
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
        final teamName = team.teamName ?? "Unnamed Team";
        final members = (team.members as List<dynamic>)
            .map((m) => m['Name'] ?? "Unknown")
            .toList();

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
