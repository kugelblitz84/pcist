import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcist/config/userConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pcist/config/socket.dart';
import 'package:pcist/secret.dart'; // adjust path if needed

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    SocketConfig.connect().then((_) {
      SocketConfig.socket.on('message', _receiveMessage);
    });
  }

  void _receiveMessage(dynamic data) {
    final decoded = data is String ? jsonDecode(data) : data;

    final message = {
      'sender': decoded['sender'],
      'text': decoded['text'],
      'time': decoded['time'],
    };

    setState(() {
      messages.add(message);
    });

    _saveMessages();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final message = {
      'sender': LoggedInUserData.name,
      'text': _controller.text.trim(),
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    };

    SocketConfig.sendMessage(jsonEncode(message));

    setState(() {
      messages.add(message);
      _controller.clear();
    });

    _saveMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('chatMessages');
    if (data != null) {
      setState(() {
        messages = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chatMessages', jsonEncode(messages));
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    bool isMe = msg['sender'] == LoggedInUserData.name;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender name
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                msg['sender'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) const SizedBox(width: 8),
              Container(
                constraints: BoxConstraints(maxWidth: 280),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color.fromARGB(255, 240, 101, 58)
                      : const Color.fromARGB(235, 100, 100, 100),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Text(
                  msg['text'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              if (isMe)
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black54,
                    child: Text(
                      msg['sender'].toString().substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          // Message time
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : 38, // match avatar spacing
              right: isMe ? 8 : 0,
            ),
            child: Text(
              msg['time'],
              style: const TextStyle(fontSize: 10, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SocketConfig.disconnect();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Groupchat(Beta)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessage(messages[index]),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
