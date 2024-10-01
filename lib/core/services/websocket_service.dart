import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'dart:convert';

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  final Logger _logger = Logger();

  Future<void> connect(String url) async {
    _logger.i('Attempting to connect to WebSocket: $url');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _logger.i('WebSocket connected successfully');
      _channel!.stream.handleError((error) {
        _logger.e('WebSocket error: $error');
        _errorController.add("WebSocket error: $error");
      });
    } catch (e) {
      _logger.e('Failed to connect to WebSocket: $e');
      _errorController.add("Failed to connect to WebSocket: $e");
    }
  }

  void send(String message) {
    try {
      _logger.i('Attempting to send WebSocket message: $message');
      if (_channel?.sink == null) {
        _logger.e('WebSocket is not connected');
        return;
      }
      _channel!.sink.add(message);
      _logger.i('WebSocket message sent successfully');
    } catch (e) {
      _logger.e('Failed to send message: $e');
      _errorController.add("Failed to send message: $e");
    }
  }

  Stream<dynamic> get stream => _channel!.stream.map((event) {
        _logger.i('Received raw WebSocket message: $event');
        if (event is String) {
          try {
            return jsonDecode(event);
          } catch (e) {
            _logger.e('Failed to parse WebSocket message as JSON: $e');
            return event;
          }
        }
        return event;
      }).handleError((error) {
        _logger.e('WebSocket stream error: $error');
      });

  Stream<String> get errorStream => _errorController.stream;

  bool isConnected() {
    return _channel != null && _channel!.closeCode == null;
  }

  void close() {
    _logger.i('Closing WebSocket connection');
    _channel?.sink.close();
    _errorController.close();
    _pingTimer?.cancel();
  }

  Timer? _pingTimer;

  void _startPingPong() {
    _pingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (isConnected()) {
        send('ping');
      }
    });
  }
}