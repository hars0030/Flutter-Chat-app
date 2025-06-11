import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'chat_screen.dart';

class UserListScreen extends StatefulWidget {
  final String currentUsername;
  final String serverUrl;

  const UserListScreen({
    Key? key,
    required this.currentUsername,
    required this.serverUrl,
  }) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<String> _users = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${widget.serverUrl}/users?username=${widget.currentUsername}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _users = data.map((user) => user['username'] as String).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : _users.isEmpty
                  ? const Center(child: Text('No other users available'))
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final username = _users[index];
                        return ListTile(
                          title: Text(username),
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  currentUsername: widget.currentUsername,
                                  peerUsername: username,
                                  serverUrl: widget.serverUrl,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
