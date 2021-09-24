import 'package:minio_client_dart/socket_service.dart';

class SocketServiceFactory {

  final String _baseUrl;

  SocketServiceFactory(this._baseUrl);

  SocketService create(String authToken) {
    final socketService = SocketService(_baseUrl);
    socketService.updateAuthToken(authToken);
    return socketService;
  } 

}