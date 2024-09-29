import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<String> _errorController = StreamController<String>.broadcast();

  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.handleError((error) {
        _errorController.add("WebSocket error: $error");
      });
    } catch (e) {
      _errorController.add("Failed to connect to WebSocket: $e");
    }
  }

  void send(String message) {
    try {
      _channel?.sink.add(message);
    } catch (e) {
      _errorController.add("Failed to send message: $e");
    }
  }

  Stream<dynamic> get stream => _channel!.stream;
  Stream<String> get errorStream => _errorController.stream;

  void close() {
    _channel?.sink.close();
    _errorController.close();
  }
}