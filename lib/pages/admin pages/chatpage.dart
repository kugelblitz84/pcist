import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
//import 'package:pcist/config/userConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pcist/config/socket.dart';
import 'package:pcist/secret.dart'; // adjust path if needed
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  bool hasMore = true;
  int skip = 0;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();

    SocketConfig.connect().then((_) {
      SocketConfig.socket.on('message', _receiveMessage);
    });

    // Detect scroll to top for loading older messages
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.minScrollExtent &&
          !isLoading &&
          hasMore) {
        _loadMoreMessages();
      }
    });
  }

  Future<void> _loadInitialMessages() async {
    await _loadMessagesFromServer();
  }

  Future<void> _loadMoreMessages() async {
    await _loadMessagesFromServer();
  }

  static Future<List<Map<String, dynamic>>> fetchChats(
    String token,
    String slug,
    int skip,
    int limit,
  ) async {
    try {
      print(
        "fetchChats called with token: $token, slug: $slug, skip: $skip, limit: $limit",
      );
      final uri = Uri.http(Secret.siteLink, '/api/v1/chat/get_chat_messages');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({'slug': slug, 'skip': skip, 'limit': limit});

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // assuming the API returns a list of messages in `data['messages']`
        return List<Map<String, dynamic>>.from(data ?? []);
      } else {
        print('Failed to fetch chats: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching chats: $e');
      return [];
    }
  }

  Future<void> _loadMessagesFromServer() async {
    setState(() => isLoading = true);
    final tokenData = await Tokenprocess.readToken();
    final token = tokenData['authToken'];
    // adjust according to your auth system
    final slug = tokenData['slug']; // set dynamically if needed

    final newMessages = await fetchChats(token ?? "", slug ?? "", skip, limit);

    setState(() {
      messages.insertAll(0, newMessages.reversed.toList()); // prepend
      skip += newMessages.length;
      hasMore = newMessages.length == limit;
      isLoading = false;
    });
  }

  void _receiveMessage(dynamic data) {
    final decoded = data is String ? jsonDecode(data) : data;
    final message = {
      'senderId': decoded['senderId'],
      'text': decoded['text'],
      'senderName': decoded['senderName'],
      'sentAt': decoded['sentAt'],
    };

    setState(() {
      messages.add(message);
    });

    _saveMessages();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final message = {
      'senderId': LoggedInUserData.id,
      'senderName': LoggedInUserData.name,
      'text': _controller.text.trim(),
      'sentAt': DateTime.now().toIso8601String(),
    };

    SocketConfig.sendMessage(jsonEncode(message));

    setState(() {
      messages.add(message);
      _controller.clear();
    });

    _saveMessages();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chatMessages', jsonEncode(messages));
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    bool isMe = msg['senderId'] == LoggedInUserData.id;

    // Parse and format sentAt timestamp string, if it's in ISO8601 format
    String formattedTime;
    try {
      DateTime dateTime = DateTime.parse(msg['sentAt']);
      formattedTime = DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
    } catch (e) {
      formattedTime = msg['sentAt'].toString(); // fallback to raw string
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender name always visible, in a smaller, lighter font
          Text(
            msg['senderName'],
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[400],
                    child: Text(
                      msg['senderName']
                          .toString()
                          .substring(0, 2)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color.fromARGB(255, 240, 101, 58)
                        : const Color.fromARGB(235, 100, 100, 100),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: Radius.circular(isMe ? 15 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 15),
                    ),
                  ),
                  child: Text(
                    msg['text'],
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              if (isMe)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black54,
                    child: Text(
                      msg['senderName']
                          .toString()
                          .substring(0, 2)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formattedTime,
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SocketConfig.disconnect();
    _controller.dispose();
    _scrollController.dispose();
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
              controller: _scrollController,
              //reverse: true, // latest messages at the bottom
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
