import 'dart:async';

import 'package:barbart/constants.dart';
import 'package:web_socket_channel/io.dart';

class APIWebSocket {
  IOWebSocketChannel channel;
  bool _connected = false;
  List<Function> _callbacks = new List<Function>();

  Timer keepAliveTimer;

  final bool autoReconnect;

  String _selfUUID = "";

  set uuid (String uuid) {
    _selfUUID = uuid;

    try { // If socket isn't connected yet, it will be and there is no need to shout an exception
      send("#" + uuid);
    } catch(e) {}
  }

  APIWebSocket({this.autoReconnect = true}) {
    start();

    // Keep alive timer that pings the server every 10 seconds
    Timer.periodic(Duration(seconds: 10), (timer) {
      send('');
    });
  }

  void start() { // Async because connection can take time
    channel = new IOWebSocketChannel.connect("ws://" + API_BASEHOST);

    channel.stream.listen(
      // A message is received
      (message) {
        executeCallbacks(message);
      },

      // Socket is closed
      onDone: autoReconnect ? () {
        start(); // Restart the connection
      } : null, // In the case there is no auto reconnect, do nothing when done.

    );

    // Authenticating
    if(_selfUUID == null || _selfUUID.length == 0) return;
    send("#" + _selfUUID);
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