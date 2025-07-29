import 'package:pcist/secret.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketConfig {
  static late IO.Socket socket;

  static Future<void> connect() async {
    socket = IO.io(
      'http://${Secret.siteLink}',
      IO.OptionBuilder()
          .setTransports(['websocket']) // Required for Flutter
          // .disableAutoConnect()
          .build(),
    );

    await socket.connect();

    socket.onConnect((_) {
      print('Connected to server: ${socket.id}');
    });

    socket.on('message', (data) {
      print('Received message: $data');
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  static void sendMessage(String message) {
    socket.emit('message', message);
  }

  static void disconnect() {
    socket.disconnect();
  }
}
