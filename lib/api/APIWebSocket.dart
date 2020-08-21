import 'package:barbart/constants.dart';
import 'package:web_socket_channel/io.dart';

class APIWebSocket {
  IOWebSocketChannel channel;
  List<Function> _callbacks = new List<Function>();

  APIWebSocket() {
    start();
  }

  void start() async { // Async because connection can take time
    channel = new IOWebSocketChannel.connect("ws://192.168.43.203:3000");

    channel.stream.listen((message) {
      executeCallbacks(message);
    });
  }

  void send(String message) {
    channel.sink.add(message);
  }

  void addCallback(Function(dynamic message) callback) {
    _callbacks.add(callback);
  }

  void executeCallbacks(dynamic message) {
    _callbacks.forEach((callback) {callback(message);});
  }

}