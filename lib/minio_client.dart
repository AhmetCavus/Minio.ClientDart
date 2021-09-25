import 'dart:async';

import 'package:minio_client_dart/auth_service.dart';
import 'package:minio_client_dart/collection_service.dart';
import 'package:minio_client_dart/connection_result.dart';
import 'package:minio_client_dart/convertable_Item.dart';
import 'package:minio_client_dart/minio_collection.dart';
import 'package:minio_client_dart/socket.events.dart';
import 'package:minio_client_dart/socket_service.dart';
import 'package:minio_client_dart/socket_service_factory.dart';
import 'package:openapi/api.dart';

import 'channel_service.dart';

class MinioClient {

    String _token = "emptyToken";
    SocketService _rootSocket;
    final AuthService _authService;
    final ChannelService _channelService;
    final CollectionService _collectionService;
    final SocketServiceFactory _socketServiceFactory;

    bool get isAuthenticated => _authService.token?.isNotEmpty;

    MinioClient(this._authService, this._collectionService, this._channelService, this._socketServiceFactory) {
      if(_authService == null) throw Exception("Invalid arguments");
      else if(_collectionService == null) throw Exception("Invalid arguments");
      else if(_channelService == null) throw Exception("Invalid arguments");
      else if(_socketServiceFactory == null) throw Exception("Invalid arguments");
      _rootSocket = _socketServiceFactory.create(_token);
    }

    static MinioClient init(String baseUrl) {
      final apiClient = ApiClient(basePath: baseUrl);
      return MinioClient(AuthService(AuthenticateApi(apiClient)), CollectionService(CollectionApi(apiClient)), ChannelService(ChannelApi(apiClient)), SocketServiceFactory(baseUrl));
    }

    Future<ConnectionResult<String>> createAccount(String email, String name, String secretId) async {
      _token = await _authService.createAccount(email, name, secretId);
      if(_token.isEmpty) throw Exception("Invalid token received. Please try again later");
      _collectionService.updateAuthToken(_token);
      _channelService.updateAuthToken(_token);
      _rootSocket.updateAuthToken(_token);
      return ConnectionResult(true, data: _token);
    }

    Future<ConnectionResult<String>> authenticate(String clientId, String secretId) async {
      _token = await _authService.authenticate(clientId, secretId);
      if(_token.isEmpty) throw Exception("Invalid token received. Please try again later");
      _collectionService.updateAuthToken(_token);
      _channelService.updateAuthToken(_token);
      _rootSocket.updateAuthToken(_token);
      return ConnectionResult(true, data: _token);
    }

    Future<MinioCollection<E>> requestCollection<E extends ConvertableItem>(ItemCreator<E> creator) async {
      if(!isAuthenticated) throw Exception("Not initialized. Ensure authentication first.");
      var collection = await _collectionService.requestCollection<E>(creator);
      return MinioCollection<E>(collection, _collectionService, _socketServiceFactory.create(_token), creator);
    }

    Future<void> subscribeForChannel(String newChannel) async {
      if(_rootSocket == null) throw Exception("Root socket is not initialized");
      if(_channelService == null) throw Exception("Channel service is not initialized");
      final channelResult = await _channelService.createChannel(newChannel);
      final connectResult = await _rootSocket.connect(newChannel);
      if(!channelResult.success) throw channelResult.ex;
      if(!connectResult.success) throw connectResult.ex;
    }

    void broadcast(dynamic data) {
      _ensureSocketIsCreated();
      _rootSocket.broadcast(data);
    }

    void subscribeForBroadcasts(Function(dynamic data) callback) {
      _ensureSocketIsCreated();
      _rootSocket.subscribeOn(SOCKET.EVENT_RECEIVE_BROADCAST, callback);
    }

    void subscribeOn<T>(String event, Function(T data) callback) {
      _ensureSocketIsCreated();
      _rootSocket.subscribeOn(event, callback);
    }

    void unsubsribeFrom<T>(String event, Function(T data) callback) {
      _ensureSocketIsCreated();
      _rootSocket.unsubscribeFrom(event, callback);
    }

    void unsubscribeFromAllEvents() {
      _ensureSocketIsCreated();
      _rootSocket.unsubscribeFromAllEvents();
    }

    void dispose() {
      if(_authService != null) {
        _authService.dispose();
      }

      if(_channelService != null) {
        _channelService.dispose();
      }

      if(_collectionService != null) {
        _collectionService.dispose();
      }

      if(_rootSocket != null) {
        _rootSocket.dispose();
      }
    }

    void _ensureSocketIsCreated() {
      if(_rootSocket == null) throw Exception("Root socket is not initialized");
      if(!_rootSocket.isConnected) throw Exception("Root socket is not connected. Subscribe first for a channel");
    }
}