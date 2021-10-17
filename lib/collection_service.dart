import 'dart:async';
import 'dart:convert';
import 'package:openapi/api.dart';
import 'convertable_Item.dart';

typedef E ItemCreator<E extends ConvertableItem>(dynamic decoded);

class CollectionService {
  final String AuthKey = "bearerAuth";

  String _token = "";
  final CollectionApi _collectionApi;

  CollectionService(this._collectionApi, [String token]) {
    if (_collectionApi == null) throw Exception("Invalid arguments");
    _token = token;
  }

  Future<List<E>> requestCollection<E extends ConvertableItem>(
      ItemCreator<E> creator,
      {String relations = ""}) async {
    _setAuthentication();
    var response =
        await _collectionApi.collectionSchemaRelationsGetWithHttpInfo(
            E.toString().toLowerCase(), relations);
    var decoded = jsonDecode(response.body);
    var mappedCollection = decoded.map((item) {
      return creator(item);
    });
    var collection = List<E>.from(mappedCollection);
    return collection;
  }

  Future<T> addItemToCollection<T extends ConvertableItem>(
      T body, ItemCreator<T> creator) async {
    _setAuthentication();
    var result = await _collectionApi.collectionSchemaPostWithHttpInfo(
        T.toString().toLowerCase(),
        body: body);
    var decoded = jsonDecode(result.body);
    return creator(decoded);
  }

  Future<T> updateItemFromCollection<T extends ConvertableItem>(
      T body, String id, ItemCreator<T> creator) async {
    _setAuthentication();
    var result = await _collectionApi.collectionSchemaIdPutWithHttpInfo(
        T.toString().toLowerCase(), id,
        body: body);
    var decoded = jsonDecode(result.body);
    return creator(decoded);
  }

  Future<T> removeItemFromCollection<T extends ConvertableItem>(
      String id, ItemCreator<T> creator) async {
    _setAuthentication();
    var result = await _collectionApi.collectionSchemaIdDeleteWithHttpInfo(
        T.toString().toLowerCase(), id);
    var decoded = jsonDecode(result.body);
    return creator(decoded);
  }

  void updateAuthToken(String token) {
    if (token.isEmpty) throw Exception("Invalid token");
    _token = token;
  }

  void _setAuthentication() {
    if (_token.isEmpty) throw Exception("Invalid token");
    _collectionApi.apiClient
        .getAuthentication<HttpBearerAuth>(AuthKey)
        .accessToken = _token;
  }

  void dispose() {
    // Dispose necessary attributes
  }
}
