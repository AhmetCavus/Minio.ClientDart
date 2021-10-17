import 'dart:async';

import 'package:minio_client_dart/auth_service.dart';
import 'package:minio_client_dart/collection_service.dart';
import 'package:minio_client_dart/connection_result.dart';
import 'package:minio_client_dart/convertable_Item.dart';
import 'package:minio_client_dart/minio_collection.dart';
import 'package:minio_client_dart/socket.events.dart';
import 'package:minio_client_dart/socket_service.dart';
import 'package:openapi/api.dart';

import 'channel_service.dart';

class MinioClient {
  String _token = "emptyToken";

  final String _baseUrl;
  final AuthService _authService;
  final ChannelService _channelService;
  final CollectionService _collectionService;
  final Set<SocketService> _sockets = Set.of([]);

  bool get isAuthenticated => _authService.token?.isNotEmpty;

  MinioClient(this._baseUrl, this._authService, this._collectionService,
      this._channelService) {
    if (_baseUrl.isEmpty) throw Exception("Invalid arguments");
    if (_authService == null)
      throw Exception("Invalid arguments");
    else if (_collectionService == null)
      throw Exception("Invalid arguments");
    else if (_channelService == null) throw Exception("Invalid arguments");
  }

  static MinioClient init(String baseUrl) {
    final apiClient = ApiClient(basePath: baseUrl);
    return MinioClient(
        baseUrl,
        AuthService(AuthenticateApi(apiClient)),
        CollectionService(CollectionApi(apiClient)),
        ChannelService(ChannelApi(apiClient)));
  }

  Future<ConnectionResult<String>> createAccount(
      String email, String name, String secretId) async {
    _token = await _authService.createAccount(email, name, secretId);
    if (_token.isEmpty)
      throw Exception("Invalid token received. Please try again later");

    _collectionService.updateAuthToken(_token);
    _channelService.updateAuthToken(_token);
    final rootSocket = SocketService(_baseUrl);
    rootSocket.updateAuthToken(_token);
    final connectionResult = await rootSocket.connect("");
    if (!connectionResult.success) {
      throw Exception(connectionResult.ex);
    }
    _sockets.add(rootSocket);
    return ConnectionResult(true, data: _token);
  }

  Future<ConnectionResult<String>> authenticate(
      String clientId, String secretId) async {
    _token = await _authService.authenticate(clientId, secretId);
    if (_token.isEmpty)
      throw Exception("Invalid token received. Please try again later");
    _collectionService.updateAuthToken(_token);
    _channelService.updateAuthToken(_token);
    final rootSocket = SocketService(_baseUrl);
    rootSocket.updateAuthToken(_token);
    final connectionResult = await rootSocket.connect("");
    if (!connectionResult.success) {
      throw Exception(connectionResult.ex);
    }
    _sockets.add(rootSocket);
    return ConnectionResult(true, data: _token);
  }

  Future<MinioCollection<E>> requestCollection<E extends ConvertableItem>(
      ItemCreator<E> creator,
      {String relations = ""}) async {
    if (!isAuthenticated)
      throw Exception("Not initialized. Ensure authentication first.");
    var collection = await _collectionService.requestCollection<E>(creator,
        relations: relations);
    return MinioCollection<E>(
        collection, _collectionService, _sockets.first, creator);
  }

  Future<void> subscribeToChannel(String namespace) async {
    if (_channelService == null)
      throw Exception("Channel service is not initialized");
    var searchedSocket = _sockets.firstWhere(
        (element) => element.namespace.toLowerCase() == namespace.toLowerCase(),
        orElse: () => null);
    if (searchedSocket == null) {
      final channelResult = await _channelService.createChannel(namespace);
      if (!channelResult.success) throw channelResult.ex;
      searchedSocket = SocketService(_baseUrl);
      searchedSocket.updateAuthToken(_token);
      _sockets.add(searchedSocket);
    }

    if (!searchedSocket.isConnected) {
      final connectResult = await searchedSocket.connect(namespace);
      if (!connectResult.success) throw connectResult.ex;
    }
  }

  void broadcast(dynamic data, {String namespace = ""}) {
    final socket = _ensureSocketIsCreated(namespace);
    socket.broadcast(data);
  }

  void subscribeForBroadcasts(Function(dynamic data) callback,
      {String namespace = ""}) {
    final socket = _ensureSocketIsCreated(namespace);
    socket.subscribeOn(SOCKET.EVENT_RECEIVE_BROADCAST, callback);
  }

  void subscribeOn<T>(String event, Function(T data) callback,
      {String namespace = ""}) {
    final socket = _ensureSocketIsCreated(namespace);
    socket.subscribeOn(event, callback);
  }

  void unsubsribeFrom<T>(String event, Function(T data) callback,
      {String namespace = ""}) {
    final socket = _ensureSocketIsCreated(namespace);
    socket.unsubscribeFrom(event, callback);
  }

  void unsubscribeFromAllEvents() {
    _sockets.forEach((element) {
      element.unsubscribeFromAllEvents();
    });
  }

  void dispose() {
    if (_authService != null) {
      _authService.dispose();
    }

    if (_channelService != null) {
      _channelService.dispose();
    }

    if (_collectionService != null) {
      _collectionService.dispose();
    }

    _clearSockets();
  }

  void _clearSockets() {
    _sockets.forEach((element) {
      element.dispose();
    });
    _sockets.clear();
  }

  SocketService _ensureSocketIsCreated(String namespace) {
    final socket = _sockets.firstWhere(
        (element) => element.namespace.toLowerCase() == namespace.toLowerCase(),
        orElse: () => null);
    if (socket == null) throw Exception("Socket is not initialized");
    if (!socket.isConnected) throw Exception("Socket is not connected.");
    return socket;
  }
}
