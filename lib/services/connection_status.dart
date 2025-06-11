import 'package:flutter/material.dart';

class ConnectionStatusBar extends StatelessWidget {
  final bool connected;

  const ConnectionStatusBar(this.connected);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      color: connected ? Colors.green : Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            connected ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            connected ? 'Connected' : 'Disconnected',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
