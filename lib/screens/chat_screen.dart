import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "../services/chat_service.dart";
import '../services/connection_status.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatService _chatService;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  String? currentRoom;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(
        serverUrl: "http://127.0.0.1:3000"); // Update for your server IP
    _initSocket();
  }

  Future<void> _initSocket() async {
    try {
      await _chatService.connect();
      setState(() => _isConnected = true);
      _chatService.listenForMessages((message) {
        setState(() {
          messages.add(message);
        });
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed: ${e.toString()}")),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _joinRoom() {
    if (_roomController.text.isNotEmpty && _nameController.text.isNotEmpty) {
      _chatService.joinRoom(_roomController.text, (history) {
        setState(() {
          currentRoom = _roomController.text;
          messages = history;
        });
        _scrollToBottom();
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty && currentRoom != null) {
      _chatService.sendMessage(
        _nameController.text,
        _messageController.text,
        currentRoom!,
      );
      _messageController.clear();
    }
  }

  void _leaveRoom() {
    setState(() {
      currentRoom = null;
      messages.clear();
    });
    _chatService.disconnect();
    _initSocket();
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            currentRoom != null ? "Room: $currentRoom" : "Join a Private Room"),
        actions: [
          if (currentRoom != null)
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: _leaveRoom,
            ),
        ],
      ),
      body: Column(
        children: [
          ConnectionStatusBar(_isConnected),
          if (currentRoom == null) _buildJoinUI(),
          if (currentRoom != null) _buildChatUI(),
        ],
      ),
    );
  }

  Widget _buildJoinUI() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Your Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                labelText: "Room ID",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _joinRoom,
              child: Text("Join Room"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatUI() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (_, index) => _buildMessageBubble(messages[index]),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message["sender"] == _nameController.text;
    final timestamp = message["timestamp"] != null
        ? DateTime.parse(message["timestamp"]).toLocal()
        : DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    message["sender"],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                Text(message["message"]),
                Text(
                  DateFormat('HH:mm').format(timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
