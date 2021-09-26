import 'dart:async';
import 'package:minio_client_dart/socket.events.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'connection_result.dart';

class SocketService {

  String _token;
  IO.Socket _socket;
  String _namespace;
  final String _baseUrl;

  String get namespace => _namespace;
  bool get isConnected => _socket == null ? false : _socket.connected;

  SocketService(this._baseUrl);

  void updateAuthToken(String token) {
    if(token.isEmpty) throw Exception("Invalid token: The token is not valid");
    _token = token;
  }

  Future<ConnectionResult> connect(String namespace) async {
    if(_token.isEmpty) throw Exception("Invalid token: Before connecting attempt, you've to set the token");
    if(_socket != null) {
      _socket.dispose();
    }
    _namespace = namespace;
    final completer = Completer<ConnectionResult>();
    final approvedNamespace = namespace.isNotEmpty ? "/${namespace}" : "";
    _socket = IO.io("$_baseUrl$approvedNamespace", IO.OptionBuilder()
      .setQuery({"token": _token })
      .setTransports(List.of(["websocket"]))
      .build());
    _socket.onConnect((data) {
      completer.complete(ConnectionResult(true, data: data));
    });
    _socket.onError((ex) {
      completer.completeError(ConnectionResult(false, ex: ex));
    });
    return completer.future;
  }

  void subscribeOnConnected(Function handler) {
    _socket.onConnect(handler);
  }

  void subscribeOnDisconnected(Function handler) {
    _socket.onDisconnect(handler);
  }

  void emitAddItem(dynamic item) {
    _socket.emit(SOCKET.COMMAND_COLLECTION_ADD_ITEM, item);
  }

  void emitRemoveItem(dynamic item) {
    _socket.emit(SOCKET.COMMAND_COLLECTION_REMOVE_ITEM, item);
  }

  void emitUpdateItem(dynamic item) {
    _socket.emit(SOCKET.COMMAND_COLLECTION_UPDATE_ITEM, item);
  }

  void broadcast(dynamic data) {
    _socket.emit(SOCKET.COMMAND_SEND_BROADCAST, data);
  }

  void subscribeOn<T>(String event, Function(T data) callback) {
    _socket.on(event, callback);
  }

  void unsubscribeFrom<T>(String event, Function(T data) callback) {
    _socket.off(event, callback);
  }

  void unsubscribeFromAllEvents() {
    _socket.clearListeners();
  }

  void dispose() {
    if(_socket == null) return;
    _socket.dispose();
  }

}