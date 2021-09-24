import 'dart:async';

import 'package:openapi/api.dart';

class AuthService {

  final AuthenticateApi _authApi;

  String _token = "";  
  String get token => _token;

  AuthService(this._authApi) {
    if(_authApi == null) throw Exception("Invalid arguments");
  }

  Future<String> authenticate(String clientId, String secretId) async {
    var body = new AuthBody();
    body.email = clientId;
    body.password = secretId;
    var result = await _authApi.authenticatePost(authBody: body);
    _token = result.token;
    return _token;
  }

  Future<String> createAccount(String clientId, String name, String secretId) async {
    var body = new AuthRegisterBody();
    body.email = clientId;
    body.username = name;
    body.password = secretId;
    var result = await _authApi.authenticateRegisterPost(authRegisterBody: body);
    _token = result.profile;
    return _token;
  }

  void dispose() {
    // Dispose necessary attributes
  }

}