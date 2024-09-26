import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  Future<void> connect(String url) async {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void send(String message) {
    _channel?.sink.add(message);
  }

  Stream<dynamic> get stream => _channel!.stream;

  void close() {
    _channel?.sink.close();
  }
}