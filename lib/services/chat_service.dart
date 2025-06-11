import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  final String serverUrl;

  ChatService({required this.serverUrl});

  Future<void> connect() async {
    socket = IO.io(serverUrl, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    socket.connect();
  }

  void joinRoom(String room, Function(List<Map<String, dynamic>>) onHistory) {
    socket.emit("joinRoom", room);
    socket.on("chatHistory", (data) {
      final history = List<Map<String, dynamic>>.from(
        (data as List).map((item) => {
              "sender": item["sender"] ?? "",
              "message": item["message"] ?? "",
              "timestamp": item["timestamp"]?.toString() ?? "",
            }),
      );
      onHistory(history);
    });
  }

  void sendMessage(String sender, String message, String room) {
    socket.emit("sendMessage", {
      "sender": sender,
      "message": message,
      "room": room,
    });
  }

  void listenForMessages(Function(Map<String, dynamic>) onMessage) {
    socket.on("receiveMessage", (data) {
      onMessage({
        "sender": data["sender"],
        "message": data["message"],
        "timestamp": data["timestamp"]?.toString() ?? "",
      });
    });
  }

  void disconnect() {
    socket.disconnect();
    socket.clearListeners();
  }
}
