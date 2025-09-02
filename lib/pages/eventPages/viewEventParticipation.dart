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
        final memberName = member.name ?? 'Unknown';
        final classroll = member.classroll?.toString() ?? 'N/A';
        final paymentStatus = member.paymentStatus ?? false;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(memberName),
            subtitle: Text('Class Roll: $classroll'),
            trailing: Icon(
              paymentStatus ? Icons.payment : Icons.payment_outlined,
              color: paymentStatus ? Colors.green : Colors.orange,
            ),
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
        final List<RegisteredMember> members = team.members;

        return Card(
          child: ExpansionTile(
            leading: const Icon(Icons.groups),
            title: Text(teamName),
            subtitle: Text('${members.length} members'),
            children: members
                .map(
                  (member) => ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(member.name ?? 'Unknown'),
                    subtitle: Text(
                      'Class Roll: ${member.classroll?.toString() ?? 'N/A'}',
                    ),
                    trailing: Icon(
                      member.paymentStatus == true
                          ? Icons.payment
                          : Icons.payment_outlined,
                      color: member.paymentStatus == true
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
