import 'dart:async';

import 'package:openapi/api.dart';

class ChannelService {

  String _token;
  final ChannelApi _channelApi;

  final String AuthKey = "bearerAuth";

  ChannelService(this._channelApi, [String token]) {
    if(_channelApi == null) throw Exception("Invalid arguments");
    _token = token;
  }

  Future<dynamic> createChannel(String channel) async {
    _setAuthentication();
    final result = await _channelApi.channelChannelIdPost(channel);
    return result;
  }

  
  void updateAuthToken(String token) {
     if(token.isEmpty) throw Exception("Invalid token");
    _token = token;
  }

  void _setAuthentication() {
    if(_token.isEmpty) throw Exception("Invalid token");
    _channelApi.apiClient.getAuthentication<HttpBearerAuth>(AuthKey).accessToken = _token;
  }

  void dispose() {
    // Dispose necessary attributes
  }

}