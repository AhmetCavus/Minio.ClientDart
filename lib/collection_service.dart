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
      {String schema = ""}) async {
    _setAuthentication();
    var response =
        await _collectionApi.collectionSchemaPopulatedGetWithHttpInfo(
            schema.isEmpty ? E.toString().toLowerCase() : schema);
    var decoded = jsonDecode(response.body);
    var mappedCollection = decoded.map((item) {
      return creator(item);
    });
    var collection = List<E>.from(mappedCollection);
    return collection;
  }

  Future<E> addItemToCollection<E extends ConvertableItem>(
      E body, ItemCreator<E> creator,
      {String schema = ""}) async {
    _setAuthentication();
    var result = await _collectionApi.collectionSchemaPostWithHttpInfo(
        schema.isEmpty ? E.toString().toLowerCase() : schema,
        body: body);
    var decoded = jsonDecode(result.body);
    return creator(decoded);
  }

  Future<E> updateItemFromCollection<E extends ConvertableItem>(
      E body, String id, ItemCreator<E> creator,
      {String schema = ""}) async {
    _setAuthentication();
    var result = await _collectionApi.collectionSchemaIdPutWithHttpInfo(
        schema.isEmpty ? E.toString().toLowerCase() : schema, id,
        body: body);
    var decoded = jsonDecode(result.body);
    return creator(decoded);
  }

  Future<E> removeItemFromCollection<E extends ConvertableItem>(
      String id, ItemCreator<E> creator,
      {String schema = ""}) async {
    _setAuthentication();
    var result = await _collectionApi.collectionSchemaIdDeleteWithHttpInfo(
        schema.isEmpty ? E.toString().toLowerCase() : schema, id);
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
