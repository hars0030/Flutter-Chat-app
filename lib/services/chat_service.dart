import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  final String serverUrl;
  Function(Map<String, dynamic>)? onMessageReceived;

  ChatService({required this.serverUrl});

  Future<void> connect() async {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    // Setup error handling
    socket.onConnectError((data) => print('Connect Error: $data'));
    socket.onError((data) => print('Error: $data'));
  }

  void joinRoom(String sender, String receiver) {
    socket.emit('joinRoom', {'sender': sender, 'receiver': receiver});

    socket.on('chatHistory', (data) {
      if (data is List) {
        final messages = data.map((msg) => _formatMessage(msg)).toList();
        onMessageReceived?.call({'type': 'history', 'messages': messages});
      }
    });
  }

  void sendMessage(String sender, String receiver, String message) {
    socket.emit('sendMessage', {
      'sender': sender,
      'receiver': receiver,
      'message': message,
    });
  }

  void listenForMessages(Function(Map<String, dynamic>) onMessage) {
    onMessageReceived = onMessage;
    socket.on('receiveMessage', (data) {
      onMessage({'type': 'message', 'message': _formatMessage(data)});
    });
  }

  Map<String, dynamic> _formatMessage(dynamic msg) {
    return {
      'sender': msg['sender'] ?? '',
      'message': msg['message'] ?? '',
      'timestamp': msg['timestamp'] != null
          ? DateTime.parse(msg['timestamp'].toString()).toLocal()
          : DateTime.now(),
    };
  }

  void disconnect() {
    socket.disconnect();
    socket.clearListeners();
  }
}
